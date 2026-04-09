Module
/////////////////////////////////////////////////////////////
module priority_encoder #(parameter int N = 8, parameter int M = $clog2(N)) (
    input  [N-1:0] input_signal,
    output reg [M-1:0] out
);
    // Default output to 0 (no active input)
    integer i;
    always @(*) begin
        out = 0;
        // Iterate from the MSB to the LSB
        for(i = N-1; i >= 0; i = i - 1) begin
            if (input_signal[i])
                out = i[M-1:0]; // assign the index (fits in M bits since N = 2^M)
        end
    end
endmodule

/////////////////////////////////////////////////////////////
// Cascaded Encoder Module
/////////////////////////////////////////////////////////////
module cascaded_encoder #(parameter int N = 8, parameter int M = $clog2(N)) (
    input  [N-1:0] input_signal,
    output [M-1:0] out,
    output [M-2:0] out_upper_half,
    output [M-2:0] out_lower_half
);

    // Divide the input into two halves:
    // Upper half: MSBs from bit N-1 downto N/2
    // Lower half: LSBs from bit (N/2 - 1) downto 0

    // Instantiate priority_encoder for the upper half.
    // Note: The upper half has width N/2 and output width M-1 (since log2(N/2) = M-1)
    wire [M-2:0] upper_index;
    priority_encoder #( .N(N/2), .M(M-1) ) upper_encoder (
        .input_signal(input_signal[N-1:N/2]),
        .out(upper_index)
    );

    // Instantiate priority_encoder for the lower half.
    wire [M-2:0] lower_index;
    priority_encoder #( .N(N/2), .M(M-1) ) lower_encoder (
        .input_signal(input_signal[N/2-1:0]),
        .out(lower_index)
    );

    // Determine if any active input exists in each half.
    wire upper_active = |input_signal[N-1:N/2];
    wire lower_active = |input_signal[N/2-1:0];

    // Combinational logic to produce the final output:
    // If the upper half is active, add an offset of N/2 to its index.
    // Otherwise, if the lower half is active, use its index.
    // If neither half is active, default to 0.
    always @(*) begin
        if (upper_active)
            out = {1'b1, upper_index};  // Concatenating 1'b1 adds the offset (N/2 = 2^(M-1))
        else if (lower_active)
            out = lower_index;
        else
            out = 0;
    end

    // Debug outputs: indices for the upper and lower halves.
    assign out_upper_half = upper_index;
    assign out_lower_half = lower_index;

endmodule