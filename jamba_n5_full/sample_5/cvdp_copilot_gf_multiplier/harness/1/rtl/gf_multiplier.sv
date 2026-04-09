module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output [3:0] result
);

    localparam irreducible_poly = 5'b10011; // irreducible polynomial x^4 + x + 1

    reg [3:0] result;

    always @(*) begin
        result = 0;
        for (int i = 0; i < 4; i = i + 1) begin
            if (B[i]) begin
                result = result XOR A;
                mult = mult << 1;
                if (mult[3]) begin
                    mult = mult ^ irreducible_poly;
                end
            end else begin
                mult = mult << 1;
                if (mult[3]) begin
                    mult = mult ^ irreducible_poly;
                end
            end
        end
    end

    assign result = result;

endmodule
