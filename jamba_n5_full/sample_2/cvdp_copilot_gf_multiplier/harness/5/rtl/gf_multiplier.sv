module gf_multiplier (
    input [7:0] A,     // Multiplicand
    input [7:0] B,     // Multiplier
    output reg [7:0] result // Result
);
    reg [7:0] temp_result;
    reg [8:0] multiplicand;
    localparam irreducible_poly = 9'b100011011; // 9‑bit irreducible polynomial

    always @(*) begin
        temp_result = 8'd0;
        multiplicand = A;

        for (i = 0; i < 8; i = i + 1) begin
            if (B[i]) begin
                temp_result = temp_result ^ multiplicand;
            end
            multiplicand = multiplicand << 1;
            if (multiplicand[8]) begin
                multiplicand = multiplicand ^ irreducible_poly;
            end
        end

        result = temp_result;
    end
endmodule
