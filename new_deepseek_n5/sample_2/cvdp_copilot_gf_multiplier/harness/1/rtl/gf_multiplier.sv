gf_multiplier
    input [3:0] A, B;
    output [3:0] result;

    reg [3:0] multiplicand, result_reg;
    reg [3:0] multiplicand_initial;

    result_reg = 0;
    multiplicand_initial = A;

    for (int i = 3; i >= 0; i--)$
    begin
        if ((B >> i) & 1) begin
            result_reg = result_reg ^ multiplicand_initial;
        end

        multiplicand_initial = (multiplicand_initial << 1) & 15;
        if (multiplicand_initial & 8) begin
            multiplicand_initial = multiplicand_initial ^ 10011;
        end
    end

    result = result_reg;