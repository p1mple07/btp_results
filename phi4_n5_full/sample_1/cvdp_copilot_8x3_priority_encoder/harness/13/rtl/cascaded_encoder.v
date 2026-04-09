Module
// Encodes an N-bit input signal and outputs the index (M = log2(N) bits)
// of the highest-priority (MSB-first) active input. Defaults to 0 if none are active.
module priority_encoder #(parameter N = 8, parameter M = $clog2(N)) (
    input  [N-1:0] input_signal,
    output reg  [M-1:0] out
);
    integer i;
    always_comb begin
        out = {M{1'b0}};  // Default to 0 if no inputs are active
        // Scan from MSB to LSB to find the first active bit.
        // Note: This loop uses SystemVerilog's "break" statement.
        for (i = N-1; i >= 0; i = i - 1) begin
            if (input_signal[i]) begin
                out = i;  // 'i' is within [0, N-1] and fits in M bits.
                break;
            end
        end
    end
endmodule

// Cascaded Encoder Module
// Processes a large N-bit input by dividing it into two halves (upper and lower)
// and encoding each half using the parameterized priority_encoder.
// Outputs:
//   out           - M-bit output representing the index of the highest-priority active input.
//   out_upper_half - (M-1)-bit output for the upper half's highest-priority active input (for debug).
//   out_lower_half - (M-1)-bit output for the lower half's highest-priority active input (for debug).
module cascaded_encoder #(parameter N = 8, parameter M = $clog2(N)) (
    input  [N-1:0] input_signal,
    output [M-1:0] out,
    output [M-2:0] out_upper_half,
    output [M-2:0] out_lower_half
);
    // Define the half-width for splitting the input signal.
    localparam HALF = N/2;
    
    // Upper half: Most Significant Half
    wire [HALF-1:0] upper_input = input_signal[N-1:HALF];
    wire [M-2:0] upper_out;
    
    // Lower half: Least Significant Half
    wire [HALF-1:0] lower_input = input_signal[HALF-1:0];
    wire [M-2:0] lower_out;
    
    // Instantiate priority_encoder for the upper half.
    // For an input of width HALF, the required output width is log2(HALF) = M-1.
    priority_encoder #(.N(HALF), .M(M-1)) upper_encoder (
        .input_signal(upper_input),
        .out(upper_out)
    );
    
    // Instantiate priority_encoder for the lower half.
    priority_encoder #(.N(HALF), .M(M-1)) lower_encoder (
        .input_signal(lower_input),
        .out(lower_out)
    );
    
    // Final output combination:
    // If the upper half has an active input, add the offset (HALF) to its index.
    // Otherwise, use the lower half's index.
    always_comb begin
        if (upper_out != 0)
            out = upper_out + HALF;
        else
            out = {1'b0, lower_out};  // Zero-extend lower_out to M bits.
    end
    
    // Debug outputs for each half.
    assign out_upper_half = upper_out;
    assign out_lower_half = lower_out;
    
endmodule