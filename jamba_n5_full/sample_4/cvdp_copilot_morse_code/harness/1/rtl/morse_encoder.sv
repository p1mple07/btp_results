module morse_encoder (
    input [7:0] ascii_in,
    output reg [9:0] morse_out,
    output reg [3:0] morse_length
);

always_comb begin
    case (ascii_in)
        41: morse_out = "01";
        42: morse_out = "1000";
        43: morse_out = "1010";
        44: morse_out = "100";
        45: morse_out = "";
        46: morse_out = "0";
        47: morse_out = "110";
        48: morse_out = "0000";
        49: morse_out = "00";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        48: morse_out = "-----";
        49: morse_out = "----.";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        50: morse_out = "..---";
        51: morse_out = "...--";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        52: morse_out = "....-";
        53: morse_out = "....-";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        54: morse_out = ".....";
        55: morse_out = ".....";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        56: morse_out = "-....";
        57: morse_out = "----.";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        58: morse_out = "---..";
        59: morse_out = "--...";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        60: morse_out = "----.";
        61: morse_out = "----.";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        62: morse_out = "----.";
        63: morse_out = "----.";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        64: morse_out = "---..";
        65: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        66: morse_out = "---..";
        67: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        68: morse_out = "---..";
        69: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        70: morse_out = "---..";
        71: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        72: morse_out = "---..";
        73: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        74: morse_out = "---..";
        75: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        76: morse_out = "---..";
        77: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        78: morse_out = "---..";
        79: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        80: morse_out = "---..";
        81: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        82: morse_out = "---..";
        83: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        84: morse_out = "---..";
        85: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        86: morse_out = "---..";
        87: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        88: morse_out = "---..";
        89: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        90: morse_out = "---..";
        91: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        92: morse_out = "---..";
        93: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        94: morse_out = "---..";
        95: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        96: morse_out = "---..";
        97: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        98: morse_out = "---..";
        99: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        100: morse_out = "---..";
        101: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        102: morse_out = "---..";
        103: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        104: morse_out = "---..";
        105: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        106: morse_out = "---..";
        107: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        108: morse_out = "---..";
        109: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        110: morse_out = "---..";
        111: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        112: morse_out = "---..";
        113: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        114: morse_out = "---..";
        115: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        116: morse_out = "---..";
        117: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        118: morse_out = "---..";
        119: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        120: morse_out = "---..";
        121: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        122: morse_out = "---..";
        123: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        124: morse_out = "---..";
        125: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

always_comb begin
    case (ascii_in)
        126: morse_out = "---..";
        127: morse_out = "---..";
        default:
            morse_out = "00000000";
    endcase
end

endmodule
