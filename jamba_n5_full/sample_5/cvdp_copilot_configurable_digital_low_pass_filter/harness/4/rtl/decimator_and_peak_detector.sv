module advanced_decimator_with_adaptive_peak_detection #(
    parameter INT N = 8,
    parameter INT DATA_WIDTH = 16,
    parameter INT DEC_FACTOR = 4
) (
    input wire clk,
    input wire reset,
    input wire valid_in,
    input vector[$] data_in [0: (N-1)],
    output wire valid_out,
    output reg [DATA_WIDTH-1:0] data_out [0: (N/DEC_FACTOR)-1],
    output reg peak_value
);
