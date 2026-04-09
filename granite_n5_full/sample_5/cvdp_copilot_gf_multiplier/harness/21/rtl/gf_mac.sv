module gf_mac #(
    parameter WIDTH = 32  // Input width, should be a multiple of 8
)(
    input [WIDTH-1:0] a,  // Multiplicand
    input [WIDTH-1:0] b,  // Multiplier
    output reg [7:0] result // 8-bit XORed result of all GF multiplications
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