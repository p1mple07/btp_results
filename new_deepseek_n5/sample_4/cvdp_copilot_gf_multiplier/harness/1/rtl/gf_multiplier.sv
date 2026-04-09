module gf_multiplier (
    input [3:0] A,
    input [3:0] B,
    output [3:0] result
);

    reg [3:0] result_reg = 0;
    reg [3:0] multiplicand_reg = A;

    repeat(4) begin
        if ((B >> $i) & 1) begin
            result_reg = result_reg ^ multiplicand_reg;
        end
        multiplicand_reg = (multiplicand_reg << 1);
        if (multiplicand_reg & 8) begin // Check MSB
            multiplicand_reg = multiplicand_reg ^ 19; // XOR with irreducible polynomial
        end
    end

    result = result_reg;
endmodule