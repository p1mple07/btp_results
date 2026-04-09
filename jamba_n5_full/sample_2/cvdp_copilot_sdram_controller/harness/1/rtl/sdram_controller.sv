module sdram_controller (
    input wire clk,
    input wire reset,
    input wire [23:0] addr,
    input wire [15:0] data_in,
    input wire read,
    input wire write,
    input wire sdram_clk,
    input wire sdram_cke,
    input wire sdram_cs,
    input wire sdram_ras,
    input wire sdram_cas,
    input wire sdram_we,
    input wire sdram_addr,
    input wire sdram_ba,
    input wire sdram_dq,
    output reg data_out,
    output reg sdram_clk,
    output reg sdram_cke,
    output reg sdram_cs,
    output wire sdram_ras,
    output wire sdram_cas,
    output wire sdram_we,
    output wire sdram_addr,
    output wire dq_out
);

reg [9:0] state;
always @(posedge clk) begin
    case (state)
        INIT: begin
            state <= IDLE;
            // initialization 10 cycles
            if (time_elapsed >= 10) state <= IDLE;
        end
        IDLE: begin
            if (!read && !write) begin
                state <= ACTIVATE;
            end else if (read) begin
                state <= READ;
            end else if (write) begin
                state <= WRITE;
            end
        end
        ACTIVATE: begin
            // activate row
            state <= READ;
        end
        READ: begin
            // perform read operation
            // output data_out
            data_out = ...;
            state <= IDLE;
        end
        WRITE: begin
            // perform write operation
            state <= IDLE;
        end
        REFRESH: begin
            // refresh operation
            state <= IDLE;
        end
    endcase
end

endmodule
