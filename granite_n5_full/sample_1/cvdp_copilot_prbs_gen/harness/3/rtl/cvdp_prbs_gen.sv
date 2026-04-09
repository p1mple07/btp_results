module cvdp_prbs_gen #(
    // Configuration parameters
    parameter int CHECK_MODE = 0,
    parameter int POLY_LENGTH = 31,
    parameter int POLY_TAP = 3,
    parameter int WIDTH = 16
) (
    input  wire clk,
    input  wire rst,
    input  wire [WIDTH-1:0] data_in,
    output      [WIDTH-1:0] data_out
);

  // Your implementation here

endmodule