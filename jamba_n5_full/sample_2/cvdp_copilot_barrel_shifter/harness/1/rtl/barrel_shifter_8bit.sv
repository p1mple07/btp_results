module barrel_shifter_8bit (
    input         data_in,
    input         shift_bits,
    input         left_right,
    output reg    data_out
);

    assign data_out = (left_right == 1) ? data_in << shift_bits : data_in >> shift_bits;

endmodule
