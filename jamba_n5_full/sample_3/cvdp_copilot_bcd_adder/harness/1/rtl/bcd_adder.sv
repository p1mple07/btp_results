module bcd_adder(
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] sum,
    output       cout
);

    // First 4-bit binary adder for BCD input
    four_bit_adder adder1(
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(binary_sum),
        .cout(binary_cout)
    );

    // Determine if correction is needed
    wire decimal_sum = binary_sum;
    wire correction = 0;

    if (decimal_sum > 9) begin
        // Add 6 (0110)
        binary_sum = {binary_sum[3:0], 4'b0110};
        cout = 1;
        correction = 1;
    end else
        cout = 0;

    // Second 4-bit adder for BCD correction
    four_bit_adder adder2(
        .a(binary_sum),
        .b({1'b0, cout, cout, 1'b0}),
        .cin(1'b0),
        .sum(sum),
        .cout(carry)
    );

endmodule
