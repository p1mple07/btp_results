module cascaded_encoder #(parameter N = 8) (
    input_signal [N-1:0],
    output out [N/2-1:0],
    output out_upper_half [N/4-1:0],
    output out_lower_half [N/4-1:0]
);

    // Instantiate two parameterized priority encoders
    priority_encoder #(N, N/2) encoder_upper (
        .input_signal(input_signal[N/4-1:0]),
        .out(out_upper_half)
    );

    priority_encoder #(N, N/2) encoder_lower (
        .input_signal(input_signal[(N/2)-1:0]),
        .out(out_lower_half)
    );

    // Determine the first active input
    assign out = (out_upper_half > out_lower_half) ? out_upper_half : out_lower_half;

endmodule
