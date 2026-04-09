module gf_mac #(parameter WIDTH=8) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [7:0] result
);
    localparam IRREDUCIBLE_POLY = 9'b100011011; // Irreducible polynomial x^8 + x^4 + x^3 + x + 1
    wire [7:0] temp_result;
    wire [WIDTH-1:0] a_segments [0:(WIDTH/8)-1];
    wire [WIDTH-1:0] b_segments [0:(WIDTH/8)-1];
    wire [WIDTH-1:0] segment_products [0:(WIDTH/8)-1];
    wire [WIDTH-1:0] segment_results [0:(WIDTH/8)-1];

    assign temp_result = 8'b0000000;

    // Split a and b into 8-bit segments
    generate
        for (genvar i = 0; i < (WIDTH/8); i = i + 1) begin
            assign a_segments[i] = a[(i*8)+:8];
            assign b_segments[i] = b[(i*8)+:8];
        end
    endgenerate

    // Calculate the product of each segment using gf_multiplier
    generate
        for (genvar i = 0; i < (WIDTH/8); i = i + 1) begin
            gf_multiplier #(
               .WIDTH(8)
            ) segment_multiplier (
               .a(a_segments[i]),
               .b(b_segments[i]),
               .result(segment_products[i])
            );

            // Apply polynomial reduction on segment products if they exceed 8 bits
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    segment_results[i] <= 8'b0000000;
                end else begin
                    if (segment_products[i][7] == 1) begin
                        segment_products[i] <= segment_products[i] ^ IRREDUCIBLE_POLY;
                    end
                    segment_results[i] <= segment_products[i] ^ segment_results[i-1];
                end
            end
        end
    endgenerate

    // Combine the segment results to obtain the final output
    assign result = segment_results[(WIDTH/8)-1];

endmodule