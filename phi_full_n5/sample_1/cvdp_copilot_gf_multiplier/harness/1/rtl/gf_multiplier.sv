module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] result
);

    // Polynomial representation of the irreducible polynomial
    localparam const bit irreducible_poly = 5'b10011;

    // Internal registers for intermediate results
    reg [3:0] temp_result;

    always_comb begin
        // Initialize result
        result = 4'b0000;

        // Iterate over each bit of B
        for (integer i = 0; i < 4; i++) begin
            // XOR result with A and shift left
            temp_result = result ^ A;
            result = {result, temp_result};

            // Shift A left by one bit
            A = {A[2:0], 1'b0};

            // Perform polynomial reduction if needed
            if (A[3]) begin
                A = A ^ irreducible_poly;
            end

            // If the current bit of B is 1
            if (B[i]) begin
                // XOR with temp_result
                result = temp_result;
            end
        end
    end

endmodule
