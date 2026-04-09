module cic_decimator #(
    parameter WIDTH = 16,
    parameter RMAX = 2,
    parameter M    = 1,
    parameter N    = 2,
    localparam REG_WIDTH = WIDTH + $clog2((RMAX * M)**N)
) (
    input wire clk,
    input wire rst,
    
    input wire [WIDTH-1:0] input_tdata,
    input wire input_tvalid,
    output wire input_tready,
    
    output reg [REG_WIDTH-1:0] output_tdata,
    output reg output_tvalid,
    input wire output_tready,
    
    input wire [N*M-1:0] rate // 0 <= rate < RMAX*(M**N)
);

// Implement the CIC decimator here...

endmodule