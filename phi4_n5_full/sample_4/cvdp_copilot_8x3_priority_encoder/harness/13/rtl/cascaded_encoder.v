module
module priority_encoder #(parameter N = 8, parameter M = $clog2(N)) (
    input  [N-1:0] input_signal,
    output reg [M-1:0] out
);
    integer i;
    always @(*) begin
        out = 0; // Default: no active input
        // Iterate from MSB to LSB to find the first active bit
        for (i = N-1; i >= 0; i = i - 1) begin
            if (input_signal[i]) begin
                out = i; // Encode the index of the active input
                break;
            end
        end
    end
endmodule

// New cascaded_encoder module that divides the input into two halves
module cascaded_encoder #(parameter N = 8, parameter M = $clog2(N)) (
    input  [N-1:0] input_signal,
    output reg  [M-1:0] out,
    output wire [M-2:0] out_upper_half,
    output wire [M-2:0] out_lower_half
);
    // Divide the input into upper and lower halves.
    // Upper half: Most significant N/2 bits.
    // Lower half: Least significant N/2 bits.
    wire [N/2-1:0] upper_signal = input_signal[N-1:N/2];
    wire [N/2-1:0] lower_signal = input_signal[N/2-1:0];

    // Instantiate priority_encoder for the upper half.
    // The output width for the half is M-1 since log2(N/2) = M - 1.
    priority_encoder #(.N(N/2), .M($clog2(N/2))) upper_encoder (
        .input_signal(upper_signal),
        .out(out_upper_half)
    );

    // Instantiate priority_encoder for the lower half.
    priority_encoder #(.N(N/2), .M($clog2(N/2))) lower_encoder (
        .input_signal(lower_signal),
        .out(out_lower_half)
    );

    // Combinational logic to select the final output.
    // If the upper half has any active input, then the overall index is the
    // upper half's index plus an offset of N/2. Otherwise, use the lower half's index.
    always @(*) begin
        if (|upper_signal)
            // Concatenate a zero to extend out_upper_half to M bits and add offset (N >> 1)
            out = {1'b0, out_upper_half} + (N >> 1);
        else
            out = out_lower_half;
    end
endmodule