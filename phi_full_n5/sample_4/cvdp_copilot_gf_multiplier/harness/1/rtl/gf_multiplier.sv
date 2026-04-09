module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] result
);

    reg [7:0] temp_result;

    always_comb begin
        result = 0;
        temp_result = A;

        for (genvar i = 0; i < 4; i++) begin
            if (B[i]) begin
                result = result ^ temp_result;
                temp_result = temp_result << 1;
                if (temp_result[7]) begin
                    temp_result = temp_result ^ 4'b10011; // Polynomial reduction
                end
            end
        end
    end

endmodule
