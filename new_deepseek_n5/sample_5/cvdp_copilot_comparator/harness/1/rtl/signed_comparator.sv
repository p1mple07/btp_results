module signed_unsigned_comparator(
    parameter WIDTH = 5,
    input i_A,
    input i_B,
    input i_enable,
    input i_mode
);

    output o_greater, o_less, o_equal;

    // Extract sign bits for signed comparison
    localparam sign_a = (i_A >> (WIDTH - 1)) & 1;
    localparam sign_b = (i_B >> (WIDTH - 1)) & 1;

    // Compare based on mode
    case (i_mode)
        1: // Signed mode
            if (sign_a != sign_b) {
                if (sign_a == 0 && sign_b == 1) {
                    o_greater = 1;
                } else {
                    o_less = 1;
                }
            } else {
                if (i_A > i_B) {
                    o_greater = 1;
                } else if (i_A < i_B) {
                    o_less = 1;
                } else {
                    o_equal = 1;
                }
            }
            // If enable is low, all outputs are low
            if (!i_enable) {
                o_greater = 0;
                o_less = 0;
                o_equal = 0;
            }
        0: // Magnitude mode
            if (i_A > i_B) {
                o_greater = 1;
            } else if (i_A < i_B) {
                o_less = 1;
            } else {
                o_equal = 1;
            }
            // If enable is low, all outputs are low
            if (!i_enable) {
                o_greater = 0;
                o_less = 0;
                o_equal = 0;
            }
    endcase

endmodule