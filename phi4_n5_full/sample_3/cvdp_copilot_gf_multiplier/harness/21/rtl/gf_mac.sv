module gf_mac #(
    parameter WIDTH = 32  // Input width, should be a multiple of 8
)(
    input [WIDTH-1:0] a,  // Multiplicand
    input [WIDTH-1:0] b,  // Multiplier
    output reg [7:0] result, // 8-bit XORed result of all GF multiplications
    output reg error_flag,   // Error flag: 1 if error, 0 otherwise
    output reg valid_result  // Valid result flag: 1 if computation is valid, 0 otherwise
);

    integer i;
    reg [7:0] temp_result;

    generate
        if (WIDTH % 8 != 0) begin: invalid_width_case
            // When WIDTH is not a multiple of 8, do not perform any computation.
            always @(*) begin
                result     = 8'b0;
                valid_result = 1'b0;
                error_flag = 1'b1;
            end
        end else begin: valid_width_case
            // Declare wire array for partial results when WIDTH is valid.
            wire [7:0] partial_results [(WIDTH/8)-1:0];

            // Generate GF multipliers for each 8-bit segment.
            genvar j;
            generate
                for (j = 0; j < WIDTH/8; j = j + 1) begin : segment_mult
                    gf_multiplier segment_mult (
                        .A(a[(j+1)*8-1:j*8]),
                        .B(b[(j+1)*8-1:j*8]),
                        .result(partial_results[j])
                    );
                end
            endgenerate

            // XOR all segment results and set output flags.
            always @(*) begin
                temp_result = 8'b0;
                for (i = 0; i < WIDTH/8; i = i + 1) begin
                    temp_result = temp_result ^ partial_results[i];
                end
                result     = temp_result;
                valid_result = 1'b1;
                error_flag = 1'b0;
            end
        end
    endgenerate
endmodule

module gf_multiplier (
    input [7:0] A,
    input [7:0] B,
    output reg [7:0] result
);
    reg [7:0] temp_result;
    reg [8:0] multiplicand;
    reg [8:0] irreducible_poly = 9'b100011011; // x^8 + x^4 + x^3 + x + 1

    integer i;

    always @(*) begin
        temp_result = 8'b00000000;
        multiplicand = {1'b0, A};
        for (i = 0; i < 8; i = i + 1) begin
            if (B[i]) begin
                temp_result = temp_result ^ multiplicand[7:0];
            end
            multiplicand = multiplicand << 1;
            if (multiplicand[8]) begin
                multiplicand = multiplicand ^ irreducible_poly;
            end
        end
        result = temp_result;
    end
endmodule