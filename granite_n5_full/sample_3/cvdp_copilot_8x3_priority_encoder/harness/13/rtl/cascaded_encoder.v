module cascaded_encoder (
    input        [N-1:0] input_signal,    // N-bit wide input signal to be encoded
    output reg   [M-1:0] out,              // M-bit wide output vector that represents the index of the highest-priority active input
    output reg   [M-2:0] out_upper_half, // M-1 bit wide output vector that represents the index of the highest-priority active input of the most significant half of data
    output reg   [M-2:0] out_lower_half    // M-1 bit wide output vector that represents the index of the highest-priority active input of the least significant half of data
);

// Number of bits in the input
parameter N = 8;
// Width of the output vector
parameter M = $clog2(N);

reg [M-1:0] upper_half;
reg [M-1:0] lower_half;

priority_encoder #(.N(N/2),.M($clog2(N/2))) encoder_upper_half (
   .input_signal(input_signal[N/2-1:0]),
   .out(upper_half)
);

priority_encoder #(.N(N/2),.M($clog2(N/2))) encoder_lower_half (
   .input_signal(input_signal[N/2-2:0]),
   .out(lower_half)
);

assign out = (upper_half > lower_half)? upper_half : lower_half;
assign out_upper_half = (upper_half > lower_half)? upper_half : lower_half + M/2;
assign out_lower_half = (upper_half > lower_half)? upper_half + M/2 : lower_half;

endmodule