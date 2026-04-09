module sdram_controller (
    input wire clk,
    input wire reset,
    input wire [23:0] addr,
    input wire [15:0] data_in,
    input wire read, write,
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
    output reg sdram_ras,
    output reg sdram_cas,
    output reg sdram_we,
    output reg sdram_addr,
    output reg sdram_ba,
    output reg sdram_dq
);

reg [3:0] state;

always @(posedge clk) begin
    case (state)
        INIT: begin
            // initialization phase, 10 clock cycles
            state <= IDLE;
        end
        IDLE: begin
            // check for read or write requests
            if (!read && !write) state <= ACTIVATE;
            if (read) state <= READ;
            if (write) state <= WRITE;
        end
        ACTIVATE: begin
            // activate the row
            state <= READ;
        end
        READ: begin
            // simulate read operation
            data_out <= sdram_dq;
            state <= IDLE;
        end
        WRITE: begin
            // simulate write operation
            data_in <= data_out;
            state <= IDLE;
        end
        REFRESH: begin
            // simulate refresh
            state <= IDLE;
        end
    endcase
end

endmodule
