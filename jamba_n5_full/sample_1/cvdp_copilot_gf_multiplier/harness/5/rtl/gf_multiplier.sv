module gf_multiplier (
    input [3:0] A,     // Multiplicand
    input [3:0] B,     // Multiplier
    output reg [7:0] result // Result
);
    reg [7:0] temp_result;
    reg [4:0] multiplicand;
    reg [4:0] irreducible_poly = 9'b100011011; // New polynomial for 8-bit

    integer i;

    always @(*) begin
        temp_result = 4'b0000; // Initialize result to zero
        multiplicand = {1'b0, A}; // Initialize multiplicand, adding an extra bit to handle overflow

        for (i = 0; i < 8; i = i + 1) begin
            if (B[i]) begin
                temp_result = temp_result ^ multiplicand; // XOR the multiplicand with result
            end
            multiplicand = multiplicand << 1; // Shift the multiplicand left by 1
            if (multiplicand[8]) begin
                multiplicand = multiplicand ^ irreducible_poly; // Polynomial reduction if overflow occurs
            end
        end

        result = temp_result; // Output the final result
    end
endmodule
