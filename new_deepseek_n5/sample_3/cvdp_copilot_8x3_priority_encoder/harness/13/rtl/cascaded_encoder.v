module cascaded_encoder (
    input       [N-1:0] input_signal,
    output reg  [M-1:0] out,
    output reg  [M-2:0] out_upper_half,
    output reg  [M-2:0] out_lower_half
);

parameter half_N = N / 2;
parameter half_M = M / 2;

// Encode upper half
priority_encoder half_encoder_upper (
    input       [half_N-1:0] upper_half,
    output reg  [half_M-1:0] out_upper_half
);
// Encode lower half
priority_encoder half_encoder_lower (
    input       [half_N-1:0] lower_half,
    output reg  [half_M-1:0] out_lower_half
);

// Determine which half has the highest priority
if (out_upper_half != 0)
 begin
     out = out_upper_half;
 end
else
 begin
     out = out_lower_half;
 end

endmodule