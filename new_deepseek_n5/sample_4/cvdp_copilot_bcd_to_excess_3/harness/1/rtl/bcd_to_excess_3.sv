module bcd_to_excess_3(
    input [3:0] bcd,
    input error_in,
    output [3:0] excess3,
    output error_out
);
    // Truth table for BCD to Excess-3 conversion
    // Valid BCD (0-9): excess3 = bcd + 3
    // Invalid BCD (10-15): excess3 = 0, error_out = 1
    case (bcd)
        0000: excess3 = 0000; error_out = 0;
        0001: excess3 = 0010; error_out = 0;
        0010: excess3 = 0011; error_out = 0;
        0011: excess3 = 0010; error_out = 0;
        0100: excess3 = 0101; error_out = 0;
        0101: excess3 = 0110; error_out = 0;
        0110: excess3 = 0111; error_out = 0;
        0111: excess3 = 0010; error_out = 0;
        1000: excess3 = 1001; error_out = 0;
        1001: excess3 = 1010; error_out = 0;
        1010: excess3 = 0000; error_out = 1;
        1011: excess3 = 0000; error_out = 1;
        1100: excess3 = 0000; error_out = 1;
        1101: excess3 = 0000; error_out = 1;
        1110: excess3 = 0000; error_out = 1;
        1111: excess3 = 0000; error_out = 1;
    endcase
endmodule