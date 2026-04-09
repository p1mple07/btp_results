module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] result
);

    // Polynomial representation of irreducible polynomial
    localparam irreducible_poly = 5'b10011;

    // Internal register to hold the multiplicand
    reg [3:0] multiplicand;

    // Internal register to hold the result
    reg [3:0] temp_result;

    // Initialization
    initial begin
        multiplicand = A;
        temp_result = 4'b0000;
    end

    // GF multiplication algorithm
    always @ (B) begin
        multiplicand = A;
        for (int i = 0; i < 4; i++) begin
            if (B[i] == 1'b1) begin
                temp_result = temp_result ^ multiplicand;
                multiplicand = {multiplicand[0], multiplicand};
                if (multiplicand[3]) begin
                    multiplicand = multiplicand ^ irreducible_poly;
                end
            end else begin
                multiplicand = {multiplicand[0], multiplicand};
                if (multiplicand[3]) begin
                    multiplicand = multiplicand ^ irreducible_poly;
                end
            end
        end
        result = temp_result;
    end

endmodule
