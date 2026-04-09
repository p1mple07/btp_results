module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input wire HCLK,
    input wire HRESETn,
    input wire HSEL,
    input wire [ADDR_WIDTH-1:0] HADDR,
    input wire HWRITE,
    input wire [DATA_WIDTH-1:0] HWDATA,
    input wire HREADY,
    output reg [DATA_WIDTH-1:0] HRDATA,
    output reg HRESP,
    output reg [DATA_WIDTH-1:0] COUNTER
);

localparam MAX_COUNT = 0xFFFF;

reg [DATA_WIDTH-1:0] counter_value = 0;
reg overflow = 0;

always @(posedge HCLK) begin
    if (HRESETn) begin
        counter_value <= 0;
        overflow <= 0;
    end else begin
        if (HADDR == ADDR_START) begin
            counter_value = 0;
        end else if (HADDR == ADDR_STOP) begin
            counter_value = 0;
        end else if (HADDR == ADDR_COUNTER) begin
            HRDATA = counter_value;
        end else if (HADDR == ADDR_OVERFLOW) begin
            overflow = 1;
        end else if (HADDR == ADDR_MAXCNT) begin
            counter_value = ADDR_MAXCNT;
        end else
            ; // default
    end
end

function automatic void reset_internal();
    counter_value <= 0;
    overflow <= 0;
endfunction

endmodule
