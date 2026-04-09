module gf_multiplier (
    input [7:0] A,     // Multiplicand (8‑bit)
    input [7:0] B,     // Multiplier (8‑bit)
    output reg [7:0] result // 8‑bit product
);

    localparam irreducible_poly = 9'b100011011;  // 9‑bit irreducible polynomial

    reg [8:0] temp_result;
    reg [8:0] multiplicand;

    always_comb begin
        temp_result = 0;
        multiplicand = 9'b00000000;  // 9‑bit initialisation with leading zero

        for (integer i = 0; i < 8; i = i + 1) begin
            if (B[i]) begin
                temp_result ^= multiplicand;
            end
            multiplicand = multiplicand << 1;
            if (multiplicand[8]) begin
                multiplicand ^= irreducible_poly;
            end
        end

        result = temp_result;
    end

endmodule
