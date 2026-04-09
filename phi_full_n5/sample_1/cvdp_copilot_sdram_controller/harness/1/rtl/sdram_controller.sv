module sdram_controller (
    input clk,
    input reset,
    input [23:0] addr,
    input [15:0] data_in,
    output reg [15:0] data_out,
    output reg sdram_clk,
    output reg sdram_cke,
    output reg sdram_cs,
    output reg sdram_ras,
    output reg sdram_cas,
    output reg sdram_we,
    input [7:0] sdram_addr,
    input [3:0] sdram_ba,
    output [15:0] sdram_dq,
    output [15:0] dq_out
);

    // State declaration
    reg [2:0] state;
    reg [3:0] row_addr;
    reg [3:0] col_addr;

    // Initialization sequence
    initial begin
        state = 0; // INIT
    end

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            row_addr <= 0;
            col_addr <= 0;
        end else if (state == 0) begin
            // 10-cycle initialization
            for (int i = 0; i < 10; i = i + 1) begin
                state <= state + 1;
                #10;
            end
            state <= 1; // IDLE
        end else if (state == 1) begin
            // Monitor for read/write request
            if (read || write) begin
                state <= 2; // ACTIVATE
            end
        end else if (state == 2) begin
            // Assert CS, RAS, CAS, and appropriate WE
            if (read) begin
                sdram_cs <= 1;
                sdram_ras <= 1;
                sdram_cas <= col_addr;
                sdram_we <= 0;
                state <= 3; // READ
            end else if (write) begin
                sdram_cs <= 1;
                sdram_ras <= 1;
                sdram_cas <= col_addr;
                sdram_we <= 1;
                state <= 4; // WRITE
            end
        end else if (state == 3 || state == 4) begin
            // Perform read/write operation
            // Assuming the operation is completed and moving back to IDLE
            state <= 1;
        end
    end

    // FSM logic for ACTIVATE, READ, and WRITE
    always @(state, addr, data_in, read, write) begin
        case (state)
            2: begin // ACTIVATE
                if (addr == row_addr) begin
                    sdram_ras <= 1;
                    state <= (read ? 3 : 4);
                end else begin
                    row_addr <= addr;
                end
            end
            3: begin // READ
                sdram_dq <= data_in;
                sdram_dq_out <= data_dq;
                state <= 1;
            end
            4: begin // WRITE
                sdram_dq <= data_out;
                state <= 1;
            end
            default: begin
                // Auto-refresh logic
                if (col_addr == 0 && state == 1 && (clk_counter % 1024 == 0)) begin
                    state <= 5; // REFRESH
                    col_addr <= 0;
                    sdram_we <= 0;
                end
            end
        endcase
    end

    // Clock counter
    reg [15:0] clk_counter = 0;
    always @(posedge clk) begin
        clk_counter <= clk_counter + 1;
    end

    // Auto-refresh command
    always @(state) begin
        case (state)
            5: begin // REFRESH
                sdram_cs <= 1;
                sdram_ras <= 1;
                sdram_cas <= col_addr;
                sdram_we <= 0;
                state <= 1;
            end
        endcase
    end

endmodule
