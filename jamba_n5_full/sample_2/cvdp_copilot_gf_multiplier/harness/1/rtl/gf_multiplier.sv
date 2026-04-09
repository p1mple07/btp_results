module gf_multiplier(input [3:0] A, input [3:0] B, output reg [3:0] result);

    localparam irreducible_poly = 5'b10011;

    always @(*) begin
        reg [3:0] a, temp;
        temp = A;
        reg result_val;

        for (int i = 0; i < 4; i++) begin
            localparam bit = b[i];
            if (bit) begin
                result_val = result_val ^ a;
                a = a << 1;
                if (a[3] == 1) begin
                    a = a ^ irreducible_poly;
                end
            end
        end

        result = result_val;
    end

endmodule
