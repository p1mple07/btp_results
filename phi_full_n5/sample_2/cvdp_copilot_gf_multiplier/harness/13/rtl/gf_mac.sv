module gf_mac #(parameter WIDTH = 8) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [7:0] result
);
    integer i;

    always @(*) begin
        result = 8'b0; // Initialize result to zero

        // Divide input vectors into segments of width WIDTH
        a = {(WIDTH/8{1'b0}), a};
        b = {(WIDTH/8{1'b0}), b};

        // Perform segmented MAC operation
        for (i = 0; i < WIDTH/8; i = i + 1) begin
            // Extract 8-bit segments
            reg [7:0] a_segment = {a[i*8-1:i*8], 1'b0};
            reg [7:0] b_segment = {b[i*8-1:i*8], 1'b0};

            // Use existing gf_multiplier module for multiplication
            reg [7:0] segment_result;
            gf_multiplier u_gf_multiplier(
                .A(a_segment),
                .B(b_segment),
                .result(segment_result)
            );

            // Perform polynomial reduction if needed
            if (segment_result[7]) begin
                segment_result = segment_result ^ 9'b100011011;
            end

            // XOR the reduced product with the cumulative result
            result = result ^ segment_result;
        end
    end
endmodule
