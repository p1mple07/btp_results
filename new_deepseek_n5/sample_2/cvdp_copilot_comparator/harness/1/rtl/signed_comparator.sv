module signed_unsigned_comparator(
    input wire [WIDTH-1:0] i_A,
    input wire [WIDTH-1:0] i_B,
    input wire i_enable,
    input wire i_mode
    ,
    output wire o_greater,
    output wire o_less,
    output wire o_equal
);

    local wire enable = ~i_enable;

    if (i_mode) // signed mode
    begin
        // Extract sign bit
        wire sign_A = (i_A[WIDTH-1] & 1) ? 1 : 0;
        wire sign_B = (i_B[WIDTH-1] & 1) ? 1 : 0;

        // Compare magnitudes based on sign
        if ((sign_A == sign_B) && (i_A[WIDTH-1:0] == i_B[WIDTH-1:0]))
            o_equal = 1;
        else if (sign_A == 0 && sign_B == 0)
        begin
            if (i_A > i_B)
                o_greater = 1;
            else if (i_A < i_B)
                o_less = 1;
            else
                o_equal = 1;
        end
        else if (sign_A == 0 && sign_B == 1)
            o_greater = 1;
        else if (sign_A == 1 && sign_B == 0)
            o_less = 1;
    end
    else // magnitude mode
    begin
        if (i_A > i_B)
            o_greater = 1;
        else if (i_A < i_B)
            o_less = 1;
        else
            o_equal = 1;
    end

    // Set outputs to low when enable is low
    if (enable)
    begin
        if (i_mode)
            // signed comparison logic
            if (i_A > i_B)
                o_greater = 1;
            else if (i_A < i_B)
                o_less = 1;
            else
                o_equal = 1;
        else
            // magnitude comparison logic
            if (i_A > i_B)
                o_greater = 1;
            else if (i_A < i_B)
                o_less = 1;
            else
                o_equal = 1;
    end

    endmodule