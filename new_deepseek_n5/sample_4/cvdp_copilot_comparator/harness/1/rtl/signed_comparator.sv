module signed_unsigned_comparator(
    parameter WIDTH = 5,
    input WIDTH i_A,
    input WIDTH i_B,
    input 1 bit i_enable,
    input 1 bit i_mode,
    output 1 bit o_greater,
    output 1 bit o_less,
    output 1 bit o_equal
);

    if (i_enable == 0)
        o_greater = 0;
        o_less = 0;
        o_equal = 0;
    else
        local bit a_sign, b_sign, a_value, b_value;
        a_sign = (i_A >> (WIDTH - 1)) & 1;
        b_sign = (i_B >> (WIDTH - 1)) & 1;
        a_value = i_A & ((1 << WIDTH) - 1);
        b_value = i_B & ((1 << WIDTH) - 1);

        if (a_sign != b_sign)
            if (a_sign == 0)
                o_greater = 1;
            else
                o_less = 1;
        else
            if (a_value > b_value)
                o_greater = 1;
            else if (a_value < b_value)
                o_less = 1;
            else
                o_equal = 1;
    end

endmodule