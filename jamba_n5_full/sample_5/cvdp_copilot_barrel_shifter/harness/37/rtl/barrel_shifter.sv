module barrel_shifter (
    input [data_width-1:0] data_in,
    input shift_bits_width,
    input left_right,
    input rotate_left_right,
    output [shift_bits_width-1:0] data_out
);

genvar dword;
generate
    for (dword = 0; dword < data_width; dword++)
        assign data_out[dword] = data_in[(dword + shift_bits_width * (left_right ^ rotate_left_right)) % data_width];
endgenerate

endmodule
