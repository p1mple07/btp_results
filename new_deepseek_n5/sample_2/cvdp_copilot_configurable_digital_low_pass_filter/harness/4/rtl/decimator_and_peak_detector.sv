// Parameters
parameter N = 8;
parameter DATA_WIDTH = 16;
parameter DEC_FACTOR = 4;

// Ports
input clock;
input reset;
input valid_in;
input [DATA_WIDTH * N - 1:0] data_in;
output [DATA_WIDTH * (N / DEC_FACTOR) - 1:0] data_out;
output [DATA_WIDTH - 1:0] peak_value;
output valid_out;

// Module implementation
rtl/decimator_and_peak_detector.sv