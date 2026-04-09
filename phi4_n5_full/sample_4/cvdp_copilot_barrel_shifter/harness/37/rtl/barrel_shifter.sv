module barrel_shifter #(parameter data_width = 16, parameter shift_bits_width = 4) (
    input  [data_width-1:0] data_in,
    input  [shift_bits_width-1:0] shift_bits,
    input  left_right,
    input  rotate_left_right,
    output [data_width-1:0] data_out
);

  // If no shifting is requested (shift_bits == 0), output remains unchanged.
  // Otherwise, perform either a standard shift or a rotate based on rotate_left_right.
  assign data_out = (shift_bits == {shift_bits_width{1'b0}}) ? data_in :
                    (rotate_left_right ?
                      (left_right ?
                         ((data_in << shift_bits) | (data_in >> (data_width - shift_bits))) :
                         ((data_in >> shift_bits) | (data_in << (data_width - shift_bits)))
                      ) :
                      (left_right ? (data_in << shift_bits) : (data_in >> shift_bits))
                    );

endmodule