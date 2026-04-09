
function [7:0] get_output(input [63:0] data_in, input [7:0] control_input);
    if (data_in == 64'h0707070707070707 && control_input == 8'b11111111) get_output = 8'h1e;
    else if (data_in == 64'hFEFEFEFEFEFEFEFE && control_input == 8'b11111111) get_output = 8'h1e;
    else if (data_in == 64'h07070707070707FD && control_input == 8'b11111111) get_output = 8'h87;
    else if (data_in[39:0] == 40'hFB07070707 && control_input == 8'b00011111) get_output = 8'h33;
    else if (data_in[39:0] == 40'h9C07070707 && control_input == 8'b00011111) get_output = 8'h2d;
    else if (data_in[7:0] == 8'hFB && control_input == 8'b00000001) get_output = 8'h78;
    else if (data_in[63:8] == 56'h070707070707FD && control_input == 8'b11111110) get_output = 8'h99;
    else if (data_in[63:16] == 48'h0707070707FD && control_input == 8'b11111100) get_output = 8'haa;
    else if (data_in[63:24] == 40'h07070707FD && control_input == 8'b11111000) get_output = 8'hb4;
    else if (data_in[63:32] == 32'h070707FD && control_input == 8'b11110000) get_output = 8'hcc;
    else if (data_in[63:40] == 24'h0707FD && control_input == 8'b11100000) get_output = 8'hd2;
    else if (data_in[63:48] == 16'h07FD && control_input == 8'b11000000) get_output = 8'hff;
    else if ({data_in[63:32], data_in[7:0]} == 40'h070707079C && control_input == 8'b11110001) get_output = 8'h4b;
    else if ({data_in[39:32], data_in[7:0]} == 16'h9C9C && control_input == 8'b00010001) get_output = 8'h55;
    else if ({data_in[39:32], data_in[7:0]} == 16'hFB9C && control_input == 8'b00010001) get_output = 8'h66;
    else get_output = 8'b0;
endfunction
