module multiplexer #(
    parameter int unsigned DATA_WIDTH = 8,
    parameter int unsigned NUM_INPUTS = 4,
    parameter bit           REGISTER_OUTPUT = 0,
    parameter bit           HAS_DEFAULT = 0,
    parameter logic [DATA_WIDTH-1:0] DEFAULT_VALUE = {DATA_WIDTH{1'b0}}
) (
    input  wire clk,
    input  wire rst_n,
    input  wire [(DATA_WIDTH*NUM_INPUTS)-1:0] inp,
    input  wire [$clog2(NUM_INPUTS)-1:0]       sel,
    input  wire bypass,
    output reg  [DATA_WIDTH-1:0] out
);

localparam int unsigned INP_WIDTH = DATA_WIDTH * NUM_INPUTS;
localparam int unsigned OUT_WIDTH = DATA_WIDTH;

// Your implementation goes here...

endmodule