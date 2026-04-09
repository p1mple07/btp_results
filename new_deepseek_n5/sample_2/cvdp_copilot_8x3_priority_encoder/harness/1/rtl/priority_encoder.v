module priority_encoder_8x3
    input [7:0] in;
    output [2:0] out;

    out = 0;
    case (in)
        8'10000000: out = 7;
        8'1000000: out = 6;
        8'100000: out = 5;
        8'10000: out = 4;
        8'01000000: out = 3;
        8'0100000: out = 2;
        8'010000: out = 1;
        8'00000001: out = 0;
        default: out = 0;
    endcase
endmodule