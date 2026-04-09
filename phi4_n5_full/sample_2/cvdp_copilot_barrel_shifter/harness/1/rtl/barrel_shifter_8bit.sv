module barrel_shifter_8bit (
    input  logic [7:0] data_in,
    input  logic [2:0] shift_bits,
    input  logic       left_right,
    output logic [7:0] data_out
);

    // If left_right is 1, perform a logical left shift;
    // if left_right is 0, perform a logical right shift.
    assign data_out = left_right ? data_in << shift_bits : data_in >>> shift_bits;

endmodule