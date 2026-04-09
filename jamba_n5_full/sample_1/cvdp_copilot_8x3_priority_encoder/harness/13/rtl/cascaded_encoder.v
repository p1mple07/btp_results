module priority_encoder #(parameter N=8) (
    input       [N-1:0] input_signal,
    output reg  [M-1:0] out
);
