module cascaded_encoder #(parameter N = 8) (
    input [N-1:0] input_signal,
    output reg [M-1:0] out,
    output reg [M-1:0] out_upper_half,
    output reg [M-1:0] out_lower_half
);
    // Calculate output width M based on parameter N
    localparam M = N > 1 ? log2ceil(N) : 1;

    // Instantiate two priority encoders for upper and lower halves
    priority_encoder #(N, M) encoder_upper(.input_signal(input_signal[N/2-1:0]), .out(out_upper_half));
    priority_encoder #(N, M) encoder_lower(.input_signal(input_signal[N/2:0]), .out(out_lower_half));

    // Determine which half has the highest priority active bit
    always @(encoder_upper.out or encoder_lower.out) begin
        if (encoder_upper.out != 0) begin
            out = encoder_upper.out;
            out_upper_half = out;
            out_lower_half = 0;
        end else if (encoder_lower.out != 0) begin
            out = encoder_lower.out;
            out_upper_half = 0;
            out_lower_half = encoder_lower.out;
        end else begin
            out = 0;
            out_upper_half = 0;
            out_lower_half = 0;
        end
    end

endmodule
