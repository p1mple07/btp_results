
module fir_filter (
    input logic clk,
    input logic reset,
    input logic signed [15:0] input_sample,
    output logic signed [15:0] output_sample,
    input logic signed [15:0] coeff0,
    input logic signed [15:0] coeff1,
    input logic signed [15:0] coeff2,
    input logic signed [15:0] coeff3
);
