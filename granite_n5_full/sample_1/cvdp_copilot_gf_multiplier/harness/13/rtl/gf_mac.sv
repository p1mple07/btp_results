module gf_mac #(parameter WIDTH=8) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [7:0] result
);
    localparam IRREDUCIBLE_POLY = 9'b100011011; // Irreducible polynomial x^8 + x^4 + x^3 + x + 1
    wire [WIDTH-1:0] a_segments [0:(WIDTH/8)-1]; // Split a into 8-bit segments
    wire [WIDTH-1:0] b_segments [0:(WIDTH/8)-1]; // Split b into 8-bit segments
    wire [7:0] segment_results [0:(WIDTH/8)-1]; // Store the results of each segment multiplication
    wire [WIDTH-1:0] temp_result; // Cumulative XOR of all segment products
    wire [WIDTH-1:0] product; // Product of two 8-bit segments
    wire overflow; // Flag indicating whether the result has overflowed
    
    assign a_segments = a >> [(WIDTH/8)*8:0]; // Extract the segments of a
    assign b_segments = b >> [(WIDTH/8)*8:0]; // Extract the segments of b
    generate
        genvar i; // Loop variable for segment indices
        for (i = 0; i < (WIDTH/8); i = i + 1) begin :gf_mac_segments
            gf_multiplier #(.WIDTH(8)) gf_mac_mul (
               .a(a_segments[i]),
               .b(b_segments[i]),
               .result(segment_results[i])
            );
        end
    endgenerate
    
    assign overflow = product[WIDTH-1]; // Check if the product has overflowed
    assign temp_result = |(segment_results & ~overflow); // Calculate the cumulative XOR of all segment products
    assign result = temp_result; // Output the final result
endmodule