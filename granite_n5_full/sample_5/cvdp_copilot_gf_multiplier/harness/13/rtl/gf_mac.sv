module gf_mac #(
    parameter WIDTH = 8
)(
    input [WIDTH-1:0] a, // Input multiplicand
    input [WIDTH-1:0] b, // Input multiplier
    output reg [7:0] result // Final result
);
    localparam SEGMENTS = WIDTH / 8; // Number of 8-bit segments
    reg [WIDTH-1:0] a_segments [SEGMENTS-1:0]; // Segments of a
    reg [WIDTH-1:0] b_segments [SEGMENTS-1:0]; // Segments of b
    wire [WIDTH-1:0] product_segments [SEGMENTS-1:0]; // Products of a_segments and b_segments
    wire [7:0] temp_result; // Intermediate result for each segment

    generate
        for (genvar i = 0; i < SEGMENTS; i = i + 1) begin : segment_loop
            assign a_segments[i] = a[(i+1)*8-1:i*8]; // Extract 8-bit segments of a
            assign b_segments[i] = b[(i+1)*8-1:i*8]; // Extract 8-bit segments of b
            assign product_segments[i] = a_segments[i] * b_segments[i]; // Multiply segments
        end
    endgenerate

    assign temp_result = (product_segments[0]) ^ (product_segments[1]) ^... ^ (product_segments[SEGMENTS-2]) ^ (product_segments[SEGMENTS-1]); // XOR products of segments

    assign result = temp_result; // Output final result

endmodule