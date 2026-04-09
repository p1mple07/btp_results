module barrel_shifter #(parameter DATA_WIDTH = 16, parameter SHIFT_BITS_WIDTH = 4) (
    input [DATA_WIDTH-1:0] data_in,
    input [SHIFT_BITS_WIDTH-1:0] shift_bits,
    input rotate_left_right,
    input left_right,
    output [DATA_WIDTH-1:0] data_out
);

    // Perform the shift or rotate operation based on the control signals
    assign data_out =
        (rotate_left_right && left_right) ?
        (((data_in << shift_bits) | (data_in >> (DATA_WIDTH - shift_bits))) << 1) :
        ((data_in >> shift_bits) << (left_right ? DATA_WIDTH - shift_bits : shift_bits));

endmodule