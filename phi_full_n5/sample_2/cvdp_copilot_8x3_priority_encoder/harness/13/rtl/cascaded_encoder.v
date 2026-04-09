module cascaded_encoder #(parameter N = 8) (
    input [N-1:0] input_signal,
    output reg [N-1:0] out,
    output reg [N-2:0] out_upper_half,
    output reg [N-2:0] out_lower_half
);

    // Calculate the width of the output vector
    localparam M = N - 1; // Since N is the bit width of the input, M is the output bit width

    // Instantiate two parameterized priority encoders for upper and lower halves
    priority_encoder #(N, M) encoder_upper (
        .input_signal(input_signal[N-1:N]),
        .out(out_upper_half)
    );

    priority_encoder #(N, M) encoder_lower (
        .input_signal(input_signal[0:N-1]),
        .out(out_lower_half)
    );

    // Determine which half has the highest priority input
    always @(input_signal) begin
        if (out_upper_half[M-1] == 1'b1) begin
            out = out_upper_half;
            out_lower_half = 32'h0; // Default LSB half to zero if MSB half is active
        end else if (out_lower_half[M-1] == 1'b1) begin
            out = out_lower_half;
            out_upper_half = 32'h0; // Default MSB half to zero if LSB half is active
        end else begin
            out = 32'h0; // No inputs are active
        end
    end

endmodule
