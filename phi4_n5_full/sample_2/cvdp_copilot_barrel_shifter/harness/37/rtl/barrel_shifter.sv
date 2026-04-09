module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input  [data_width-1:0] data_in,
    input  [shift_bits_width-1:0] shift_bits,
    input  left_right,
    input  rotate_left_right,
    output [data_width-1:0] data_out
);

    // Standard shift operation: left shift if left_right is high, right shift if low.
    wire [data_width-1:0] shift_result;
    assign shift_result = left_right ? (data_in << shift_bits) : (data_in >> shift_bits);

    // Rotate operation: bits shifted out from one end are wrapped around to the other.
    wire [data_width-1:0] rotate_result;
    assign rotate_result = left_right ?
                              ((data_in << shift_bits) | (data_in >> (data_width - shift_bits))) :
                              ((data_in >> shift_bits) | (data_in << (data_width - shift_bits)));

    // If shift_bits is 0, no shifting or rotating is performed.
    // Otherwise, select between rotate and shift based on rotate_left_right.
    assign data_out = (shift_bits == 0) ? data_in : (rotate_left_right ? rotate_result : shift_result);

endmodule