module cascaded_encoder #(parameter N = 8) (
    input_signal [N-1:0],
    output out [N/2-1:0],
    output out_upper_half [N/4-1:0],
    output out_lower_half [N/4-1:0]
);

    wire [N/4-1:0] in_upper_half [N/4-1:0];
    wire [N/4-1:0] in_lower_half [N/4-1:0];

    // Divide input_signal into upper and lower halves
    assign in_upper_half = input_signal[N/2-1:0];
    assign in_lower_half = input_signal[N/4-1:0];

    // Instantiate two parameterized priority encoders
    parameter M = N/2-1;
    priority_encoder #(M) encoder_upper (
        .input_signal(in_upper_half),
        .out(out)
    );

    parameter M = N/4-1;
    priority_encoder #(M) encoder_lower (
        .input_signal(in_lower_half),
        .out(out_lower_half)
    );

    // Determine which half has the first active input
    wire first_active_bit;
    assign first_active_bit = ((out !== out_lower_half) && (out !== out_upper_half)) ? 1'b1 : 1'b0;

    // Combine the outputs of the two encoders
    assign out = first_active_bit ? out_upper_half : out_lower_half;

endmodule
