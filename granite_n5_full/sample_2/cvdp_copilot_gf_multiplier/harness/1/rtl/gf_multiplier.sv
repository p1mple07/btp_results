module gf_multiplier (
    input [3:0] A, // 4-bit multiplicand
    input [3:0] B, // 4-bit multiplier
    output reg [3:0] result // 4-bit product output
);

    always @(*) begin
        result <= 4'b0;

        int i;
        int multiplicand = A;
        for (i=0; i<4; i++) begin
            if (B[i]) begin
                result <= result ^ multiplicand;
                if (multiplicand[3]) begin
                    multiplicand <= {multiplicand[2:0], (multiplicand[3] ^ 1) & $past(5'b10011)};
                end else begin
                    multiplicand <= {multiplicand[2:0], 0};
                end
            end else begin
                if (multiplicand[3]) begin
                    multiplicand <= {multiplicand[2:0], (multiplicand[3] ^ 1) & $past(5'b10011)};
                end else begin
                    multiplicand <= {multiplicand[2:0], 0};
                end
            end
        end
    end
endmodule