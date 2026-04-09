module binary_to_one_hot_decoder_sequencial(
    parameter BINARY_WIDTH,
    parameter OUTPUT_WIDTH,
    input i_binary_in,
    input i_clk,
    input i_rstb,
    output o_one_hot_out
);
    wire current_value;
    
    always @ (i_clk, i_rstb) begin
        if (i_rstb) begin
            current_value = 0;
        else
            current_value = i_binary_in;
        end
    end
    
    case (current_value)
        0: o_one_hot_out = 0;
        1: o_one_hot_out = 1 << 0;
        2: o_one_hot_out = 1 << 1;
        3: o_one_hot_out = 1 << 2;
        4: o_one_hot_out = 1 << 3;
        5: o_one_hot_out = 1 << 4;
        6: o_one_hot_out = 1 << 5;
        7: o_one_hot_out = 1 << 6;
        8: o_one_hot_out = 1 << 7;
        9: o_one_hot_out = 1 << 8;
        10: o_one_hot_out = 1 << 9;
        11: o_one_hot_out = 1 << 10;
        12: o_one_hot_out = 1 << 11;
        13: o_one_hot_out = 1 << 12;
        14: o_one_hot_out = 1 << 13;
        15: o_one_hot_out = 1 << 14;
        16: o_one_hot_out = 1 << 15;
        17: o_one_hot_out = 1 << 16;
        18: o_one_hot_out = 1 << 17;
        19: o_one_hot_out = 1 << 18;
        20: o_one_hot_out = 1 << 19;
        21: o_one_hot_out = 1 << 20;
        22: o_one_hot_out = 1 << 21;
        23: o_one_hot_out = 1 << 22;
        24: o_one_hot_out = 1 << 23;
        25: o_one_hot_out = 1 << 24;
        26: o_one_hot_out = 1 << 25;
        27: o_one_hot_out = 1 << 26;
        28: o_one_hot_out = 1 << 27;
        29: o_one_hot_out = 1 << 28;
        30: o_one_hot_out = 1 << 29;
        31: o_one_hot_out = 1 << 30;
        default: o_one_hot_out = 0;
    endcase
endmodule