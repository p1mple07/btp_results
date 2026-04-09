module sdram_controller (
    input clk,
    input reset,
    input [24:0] addr,
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
    output [15:0] sdram_dq,
    output [15:0] dq_out
);

    // State declaration
    typedef enum logic [1:0] {
        INIT,
        IDLE,
        ACTIVATE,
        READ,
        WRITE,
        REFRESH
    } state_t;

    state_t current_state, next_state;

    // State register
    reg [1:0] state_reg;

    // Comparator for IDLE timeout
    reg [31:0] idle_counter;

    // FSM implementation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= INIT;
            state_reg <= 2'b00;
            idle_counter <= 0;
        end else begin
            idle_counter <= idle_counter + 1;
            if (idle_counter >= 1024) begin
                current_state <= REFRESH;
                idle_counter <= 0;
            end else begin
                current_state <= state_reg;
            end
        end
    end

    // State transition logic
    always @(*) begin
        case (current_state)
            INIT: begin
                state_reg <= 2'b01;
            end
            IDLE: begin
                if (data_in) begin
                    if (read) begin
                        state_reg <= ACTIVATE;
                    end else if (write) begin
                        state_reg <= ACTIVATE;
                    end
                end else if (idle_counter >= 1024) begin
                    state_reg <= REFRESH;
                    idle_counter <= 0;
                end
            end
            ACTIVATE: begin
                sdram_cs <= 1;
                sdram_ras <= 1;
                sdram_cas <= 1;
                sdram_we <= 0;
                sdram_addr <= addr;
                sdram_ba <= 1;
            end
            READ: begin
                sdram_cs <= 1;
                sdram_cke <= 1;
                sdram_ras <= 0;
                sdram_cas <= 1;
                sdram_we <= 0;
                sdram_addr <= addr;
                sdram_ba <= 1;
                next_state <= READ;
            end
            WRITE: begin
                sdram_cs <= 1;
                sdram_cke <= 1;
                sdram_ras <= 0;
                sdram_cas <= 1;
                sdram_we <= 1;
                sdram_addr <= addr;
                sdram_ba <= 1;
                next_state <= WRITE;
            end
            REFRESH: begin
                sdram_cs <= 1;
                sdram_cke <= 1;
                sdram_ras <= 1;
                sdram_cas <= 1;
                sdram_we <= 0;
                sdram_addr <= addr;
                sdram_ba <= 1;
                next_state <= IDLE;
            end
            default: next_state <= IDLE;
        endcase
    end

    // State transition logic
    always @(posedge clk) begin
        if (current_state != next_state) begin
            state_reg <= next_state;
        end
    end

    // Output logic for READ and WRITE operations
    always @(state_reg) begin
        case (state_reg)
            READ: begin
                data_out <= sdram_dq;
            end
            WRITE: begin
                dq_out <= data_in;
            end
            default: data_out <= 0;
            dq_out <= 0;
        endcase
    end

endmodule
