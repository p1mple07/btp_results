module gf_multiplier #(parameter WIDTH = 8) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [WIDTH-1:0] result
);
    integer i;
    reg [8:0] temp_result;
    reg [8:0] irreducible_poly = 9'b100011011; // Irreducible polynomial x^8 + x^4 + x^3 + x + 1

    always @(*) begin
        temp_result = 9'b00000000; // Initialize result to zero
        result = 9'b0; // Initialize result to zero

        for (i = 0; i < WIDTH; i = i + 1) begin
            if (b[i]) begin
                temp_result = temp_result ^ a; // XOR multiplicand with result
            end
            a = {1'b0, a}; // Shift multiplicand left by 1
            if (a[8]) begin
                a = a ^ irreducible_poly; // Polynomial reduction if overflow occurs
            end
        end

        result = temp_result; // Output the final result
    end
endmodule
