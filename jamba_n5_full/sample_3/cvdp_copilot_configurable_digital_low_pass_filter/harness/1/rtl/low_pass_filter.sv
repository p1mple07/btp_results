module low_pass_filter #(
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH = 16,
    parameter NUM_TAPS = 8
)(
    input logic clk,
    input logic reset,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic valid_in,
    input logic [COEFF_WIDTH-1:0] coeffs,

    output logic [NBW_MULT + $clog2(NUM_TAPS) - 1:0] data_out,
    output logic valid_out
);
