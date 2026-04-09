module cascaded_encoder (#(int N) input_signal, N) (
    input [N-1:0] input_signal,
    output reg [M-1:0] out_upper,
    output reg [M-1:0] out_lower,
    output reg out
);

    localvar int mid = N / 2;

    priority_encoder #(N) upper_enc (
        .input_signal(input_signal[0:mid-1]),
        .out(upper_enc_out),
        .out_upper_half(upper_enc_upper_half),
        .out_lower_half(upper_enc_lower_half)
    );

    priority_encoder #(N) lower_enc (
        .input_signal(input_signal[mid:N-1]),
        .out(lower_enc_out),
        .out_upper_half(lower_enc_upper_half),
        .out_lower_half(lower_enc_lower_half)
    );

    assign out_upper = upper_enc_out;
    assign out_lower = lower_enc_out;
    assign out = (upper_enc_out[0] == 1'b1) ? (upper_enc_out + 1) : out;
endmodule
