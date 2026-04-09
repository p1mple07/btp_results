module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] result
);

    reg [3:0] multiplicand;
    reg [3:0] temp_result;
    localparam irreducible_poly = 5'b10011;

    initial begin
        multiplicand = A;
        result = 0;
    end

    always_comb begin
        temp_result = 0;
        foreach (B[i]; i in 0..3) begin
            if (B[i]) begin
                result = result ^ multiplicand;
                shifted_multiplicand = multiplicand << 1;
                if (shifted_multiplicand[3'd3]) begin
                    multiplicand = multiplicand ^ irreducible_poly;
                end
            end else {
                shifted_multiplicand = multiplicand << 1;
            }
        end
    end

endmodule
