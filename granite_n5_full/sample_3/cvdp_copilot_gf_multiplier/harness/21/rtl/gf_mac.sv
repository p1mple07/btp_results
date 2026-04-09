module gf_mac #(
    parameter WIDTH = 32  // Input width, should be a multiple of 8
)(
    input [WIDTH-1:0] a,  // Multiplicand
    input [WIDTH-1:0] b,  // Multiplier
    output reg [7:0] result,
    output reg [1:0] error_flag, // 0: No error, 1: Invalid width
    output reg valid_result // 0: Invalid computation, 1: Valid computation
);

    integer i;
    reg [7:0] temp_result;
    reg [7:0] partial_results [(WIDTH/8)-1:0];
    reg [8:0] multiplicand;
    reg [8:0] irreducible_poly = 9'b100011011; // x^8 + x^4 + x^3 + x + 1

    always @(*) begin
        valid_result = 0; // Assume no valid computation
        error_flag = 0; // Assume no error

        if (WIDTH % 8!= 0) begin
            error_flag = 1; // Set error flag if invalid width
        end else begin
            temp_result = 8'b00000000; // Initialize result to 0

            // Generate GF multipliers for each 8-bit segment
            for (i = 0; i < WIDTH/8; i = i + 1) begin
                multiplicand = {1'b0, a[(i+1)*8-1:i*8]};

                // PerformGF multiplication
                for (int j = 0; j < 8; j = j + 1) begin
                    if (b[j]) begin
                        temp_result = temp_result ^ multiplicand[7:0];
                    end
                    multiplicand = multiplicand << 1;

                    // Check for irreducible polynomial condition
                    if (multiplicand[8]) begin
                        multiplicand = multiplicand ^ irreducible_poly;
                    end
                end
            }

            valid_result = 1; // Set valid result if computation successful
            result = temp_result; // Output the computed result
        end
    end
endmodule