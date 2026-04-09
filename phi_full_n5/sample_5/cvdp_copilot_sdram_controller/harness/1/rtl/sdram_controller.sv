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
    output reg sdram_addr,
    output reg sdram_ba,
    output [15:0] dq_out
);

    // State machine and control signals
    reg [2:0] state;
    reg [1:0] next_state;

    // FSM state transition logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= 2'b00; // INIT state
        else
            state <= next_state;
    end

    // Next state logic for each state
    always @(*) begin
        case (state)
            2'b00: begin
                next_state = 2'b01; // Transition to IDLE after initialization
            end
            2'b01: begin
                if (read || write) begin
                    next_state = (read) ? 2'b02 : 2'b03; // Transition to READ/WRITE based on read/write signal
                end else begin
                    next_state = 2'b00; // Return to IDLE after 1024 cycles
                end
            end
            2'b02: begin
                sdram_cs <= 1'b1;
                sdram_ras <= 1'b1;
                sdram_cas <= 1'b1;
                if (data_in != 16'b0000_0000) begin
                    sdram_we <= 1'b0;
                end else begin
                    sdram_we <= 1'b1;
                end
                next_state = 2'b03; // Transition to READ/WRITE operation
            end
            2'b03: begin
                if (data_in != 16'b0000_0000) begin
                    sdram_dq <= data_in;
                    sdram_out <= data_out;
                    sdram_we <= 1'b0;
                end else begin
                    sdram_we <= 1'b1;
                end
                next_state = 2'b00; // Return to IDLE after operation
            end
        endcase
    end

    // Output logic for ACTIVATE command
    always @(*) begin
        sdram_cs <= 1'b1;
        sdram_ras <= 1'b1;
        sdram_cas <= 1'b1;
        sdram_we <= 1'b0;
    end

    // Output logic for READ command
    always @(*) begin
        sdram_cs <= 1'b1;
        sdram_ras <= 1'b0;
        sdram_cas <= 1'b1;
        sdram_we <= 1'b0;
        sdram_addr <= addr;
    end

    // Output logic for WRITE command
    always @(*) begin
        sdram_cs <= 1'b1;
        sdram_ras <= 1'b0;
        sdram_cas <= 1'b1;
        sdram_we <= 1'b1;
        sdram_addr <= addr;
    end

endmodule
