module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output [3:0] result
);

    reg [3:0] result;
    reg [3:0] multiplicand;
    reg [4:0] shifted_mult;

    literal poly = 5'b10011;

    for (i = 0; i < 4; i = i + 1) begin
        if ((B >> i) & 1) begin
            result = result ^ multiplicand;
        end

        shifted_mult = multiplicand << 1;
        if (shifted_mult[4]) begin
            shifted_mult = shifted_mult ^ poly;
        end
        multiplicand = shifted_mult[3:0];
    end

    result = result;
endmodule