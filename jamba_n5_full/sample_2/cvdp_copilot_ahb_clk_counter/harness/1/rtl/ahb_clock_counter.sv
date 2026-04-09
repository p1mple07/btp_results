`timescale 1ns / 1ps

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

// Internal registers
reg [DATA_WIDTH-1:0] counter;
reg overflow;

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        HRDATA <= 0;
        HRESP <= 1'b0;
        COUNTER <= 0;
        overflow <= 1'b0;
    end
    else begin
        if (HWRITE) begin
            if (HADDR == ADDR_START) begin
                counter <= 0;
            end
            else if (HADDR == ADDR_STOP) begin
                counter <= 0;
            end
            else if (HADDR == ADDR_OVERFLOW) begin
                overflow <= 1'b1;
            end
            else if (HADDR == ADDR_COUNTER) begin
                HRDATA <= counter;
            end
        end
    end
end

endmodule
