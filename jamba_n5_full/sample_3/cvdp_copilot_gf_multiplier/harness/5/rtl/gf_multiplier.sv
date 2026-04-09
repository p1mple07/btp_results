module gf_multiplier (
    input [7:0] A,     // Multiplicand
    input [7:0] B,     // Multiplier
    output reg [7:0] result // Result
);

    localparam irreducible_poly = 9'b100011011; // 8-bit polynomial for 8-bit GF

    reg [7:0] temp_result;
    reg [7:0] multiplicand;
    reg [7:0] temp_temp;

    always @(*) begin
        multiplicand = A;
        temp_result = 8'b0;

        for (int i = 0; i < 8; i = i + 1) begin
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
