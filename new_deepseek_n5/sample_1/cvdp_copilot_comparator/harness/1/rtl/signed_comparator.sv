module signed_unsigned_comparator(
    parameter WIDTH,
    input i_A,
    input i_B,
    input i_enable,
    input i_mode,
    output o_greater,
    output o_less,
    output o_equal
);
    // Check if enable is high before proceeding
    if (i_enable) {
        // Handle signed mode
        if (i_mode) {
            // Extract sign bit
            bit [WIDTH-1:0] sign_A = i_A >> (WIDTH-1);
            bit [WIDTH-1:0] sign_B = i_B >> (WIDTH-1);
            
            // Compute two's complement if negative
            bit [WIDTH-1:0] a, b;
            a = (sign_A & 1) ? (i_A ^ ((1 << WIDTH) - 1)) : i_A;
            b = (sign_B & 1) ? (i_B ^ ((1 << WIDTH) - 1)) : i_B;
            
            // Compare
            o_greater = a > b;
            o_less = a < b;
            o_equal = a == b;
        }
        // Handle magnitude mode
        else {
            // Mask out sign bit
            bit [WIDTH-1:0] a = i_A & ((1 << WIDTH) - 1);
            bit [WIDTH-1:0] b = i_B & ((1 << WIDTH) - 1);
            
            // Compare
            o_greater = a > b;
            o_less = a < b;
            o_equal = a == b;
        }
    }
    // Outputs are low when enable is low
    else {
        o_greater = 0;
        o_less = 0;
        o_equal = 0;
    }
endmodule