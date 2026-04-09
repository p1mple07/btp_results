module sdram_controller (
    input wire clk,
    input wire reset,
    input wire [31:0] addr,
    input wire data_in[15:0],
    input wire read, write, sdram_clk,
    input wire sdram_cke, sdram_cs, sdram_ras, sdram_cas, sdram_we, sdram_addr,
    output reg data_out[15:0],
    output reg sdram_clk,
    output reg [31:0] sdram_cke,
    output reg [31:0] sdram_cs,
    output reg [31:0] sdram_ras,
    output reg [31:0] sdram_cas,
    output reg [31:0] sdram_we,
    output reg sdram_addr,
    output reg [31:0] sdram_ba,
    output reg [31:0] sdram_dq,
    output reg dq_out
);

// State machine
reg [3:0] state;
always @(posedge clk) begin
    case(state)
        INIT: begin
            // initialize for 10 clock cycles
            state <= IDLE;
            // do 10 cycles: simple simulation
            #10 state <= IDLE;
            // after 10 cycles, go to IDLE? But maybe we just stay in IDLE?
        end
        IDLE: begin
            // monitor for read/write/refresh
            if (!read && !write && !sdram_refresh) begin
                state <= ACTIVATE;
            end
            if (write) begin
                state <= WRITE;
            end else if (read) begin
                state <= READ;
            end else begin
                state <= IDLE;
            end
        end
        ACTIVATE: begin
            // activate row
            state <= READ;
        end
        READ: begin
            // perform read
            state <= WRITE;
        end
        WRITE: begin
            // perform write
            state <= REFRESH;
        end
        REFRESH: begin
            // refresh rows
            state <= IDLE;
        end
    endcase
end

assign dq_out = sdram_dq;
assign sdram_clk = clk;
assign sdram_cke = sdram_cke;
assign sdram_cs = sdram_cs;
assign sdram_ras = sdram_ras;
assign sdram_cas = sdram_cas;
assign sdram_we = sdram_we;
assign sdram_addr = addr;
assign sdram_ba = ba;
assign sdram_dq = dq;
assign dq_out = dq_out;

endmodule
