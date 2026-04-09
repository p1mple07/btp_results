module signed_unsigned_comparator(
    parameter WIDTH = 5,
    input WIDTH i_A,
    input WIDTH i_B,
    input 1 bit i_enable,
    input 1 bit i_mode
);
    output 1 bit o_greater, o_less, o_equal;
    
    if (i_enable) begin
        if (i_mode) begin
            // Signed comparison
            local bit signA = (i_A >> (WIDTH-1)) & 1;
            local bit signB = (i_B >> (WIDTH-1)) & 1;
            
            if (signA != signB) begin
                if (signA == 0 && signB == 1) begin
                    o_greater = 1;
                    o_less = 0;
                    o_equal = 0;
                else begin
                    o_greater = 0;
                    o_less = 1;
                    o_equal = 0;
                end
            else begin
                o_greater = (i_A > i_B);
                o_less = (i_A < i_B);
                o_equal = (i_A == i_B);
            end
        else
        // Magnitude comparison
            local bit unsignedA = i_A & ((1 << WIDTH) - 1);
            local bit unsignedB = i_B & ((1 << WIDTH) - 1);
            
            o_greater = (unsignedA > unsignedB);
            o_less = (unsignedA < unsignedB);
            o_equal = (unsignedA == unsignedB);
        end
    else
    // All outputs low when enable is low
    o_greater = 0;
    o_less = 0;
    o_equal = 0;
endmodule