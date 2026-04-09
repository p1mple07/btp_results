module cascaded_encoder #(parameter N = 8) (
    input_signal [N-1:0] input_signal,
    output reg [M-1:0] out,
    output reg [M-2:0] out_upper_half,
    output reg [M-2:0] out_lower_half
);

    // Calculate the width of the output based on the input width
    integer M = N > 1 ? ceil(N/2) : 0;

    // Instantiate two priority encoders for the upper and lower halves
    priority_encoder #(N, M) encoder_upper (.input_signal(input_signal[N/2-1:0]), .out(out_upper_half));
    priority_encoder #(N, M) encoder_lower (.input_signal(input_signal[N/2:0]), .out(out_lower_half));

    // Determine which half has the active input
    always @(input_signal) begin
        if (out_upper_half[M-1]) begin
            out = out_upper_half;
        end else if (out_lower_half[M-1]) begin
            out = out_lower_half;
        end else begin
            out = 3'b0; // Default case when no inputs are active
        end
    end

endmodule
