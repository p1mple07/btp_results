module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] result
);

    always @(A or B) begin
        result = 4'b0000;
        integer i;
        for (i = 0; i < 4; i = i + 1) begin
            if (B[i]) begin
                result = result ^ A;
                A = A << 1;
                if (A[3]) begin
                    A = A ^ 4'b10011; // Polynomial reduction
                end
            end
            else begin
                A = A << 1;
                if (A[3]) begin
                    A = A ^ 4'b10011; // Polynomial reduction
                end
            end
        end
    end

endmodule
