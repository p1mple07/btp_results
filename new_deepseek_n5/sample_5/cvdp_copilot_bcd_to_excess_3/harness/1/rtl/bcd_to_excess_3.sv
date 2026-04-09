module bcd_to_excess_3 (
    input [3:0] bcd,
    output [3:0] excess3,
    output error
);

    case (bcd)
        8'b0000: excess3 = 4'b0011; error = 0;
        8'b0001: excess3 = 4'b0010; error = 0;
        8'b0010: excess3 = 4'b0001; error = 0;
        8'b0011: excess3 = 4'b0000; error = 0;
        8'b0100: excess3 = 4'b0111; error = 0;
        8'b0101: excess3 = 4'b0110; error = 0;
        8'b0110: excess3 = 4'b0101; error = 0;
        8'b0111: excess3 = 4'b0100; error = 0;
        8'b1000: excess3 = 4'b1011; error = 0;
        8'b1001: excess3 = 4'b1010; error = 0;
        default:
            excess3 = 4'b0000;
            error = 1;
    endcase

endmodule