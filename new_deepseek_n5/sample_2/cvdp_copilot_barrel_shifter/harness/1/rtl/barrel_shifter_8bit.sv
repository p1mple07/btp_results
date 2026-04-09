module barrel_shifter_8bit (
    input data_in,
    input shift_bits,
    input left_right,
    output data_out
);

parameter shift_reg = [
    // shift 0
    (data_in, data_in),
    // shift 1
    (data_in << 1, data_in >> 1),
    // shift 2
    (data_in << 2, data_in >> 2),
    // shift 3
    (data_in << 3, data_in >> 3),
    // shift 4
    (data_in << 4, data_in >> 4),
    // shift 5
    (data_in << 5, data_in >> 5),
    // shift 6
    (data_in << 6, data_in >> 6),
    // shift 7
    (data_in << 7, data_in >> 7)
];

data_out = shift_reg[shift_bits][left_right];

endmodule