module cic_decimator #(
    parameter int WIDTH = 16,
    parameter int RMAX = 2,
    parameter int M = 1,
    parameter int N = 2
)(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] input_tdata,
    input wire input_tvalid,
    output wire output_tvalid,
    input wire output_tready,
    output wire [REG_WIDTH-1:0] output_tdata,
    input wire [RMAX-1:0] rate
);

    localparam int REG_WIDTH = WIDTH + $clog2((RMAX * M)**N);

    // Define internal registers and variables here...

    // Implement the integrate_stage module instantiation here...

    // Implement the comb_stage module instantiation here...

    // Implement the decimation control logic here...

    // Connect input and output ports accordingly...

endmodule