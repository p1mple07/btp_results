module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] result
);

    // Internal registers
    reg [3:0] temp_multiplicand;

    // Initialization
    always @* begin
        result = 4'b0000;
        temp_multiplicand = A;
    end

    // Multiplication algorithm
    always @(A or B) begin
        result = 4'b0000;
        temp_multiplicand = A;

        for (int i = 0; i < 4; i = i + 1) begin
            if (B[i] == 1'b1) begin
                result = result ^ temp_multiplicand;
                temp_multiplicand = temp_multiplicand << 1;
                if (temp_multiplicand[3]) begin
                    temp_multiplicand = temp_multiplicand ^ 4'b10011;
                end
            end else begin
                temp_multiplicand = temp_multiplicand << 1;
                if (temp_multiplicand[3]) begin
                    temp_multiplicand = temp_multiplicand ^ 4'b10011;
                end
            end
        end
    end

endmodule
