module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule


module four_bit_adder(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] sum,
    output cout
);

    wire [2:0] carry;

    genvar i;

    generate
        for (i = 0; i < 4; i++) begin
            assign carry[i] = carry[i+1] & cin;
        end
    endgenerate

    assign sum = a + b + cin;
    assign cout = (a + b + cin) > 1;

endmodule


module bcd_adder(
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] sum,
    output       cout
);

    wire [3:0] binary_sum;
    wire [3:0] a_bin, b_bin;

    // Binary addition of the two 4‑bit BCD inputs
    four_bit_adder adder1(
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(binary_sum),
        .cout(binary_cout)
    );

    // BCD correction logic
    four_bit_adder adder2(
        .a(binary_sum),
        .b(6),            // 6 in binary (0110)
        .cin(1'b0),
        .sum(sum),
        .cout(carry)
    );

    // Determine if correction is needed
    always @(*) begin
        if (binary_sum[3:0] > 9) begin
            sum = binary_sum + 6;
            cout = 1;
        end else
            sum = binary_sum;
            cout = 0;
        end
    end

endmodule
