module barrel_shifter #(parameter data_width = 16, parameter shift_bits_width = 4)
(
    input  [data_width-1:0] data_in,
    input  [shift_bits_width-1:0] shift_bits,
    input  left_right,
    input  rotate_left_right,
    output [data_width-1:0] data_out
);

  // If shift_bits is 0, no shifting or rotation is performed.
  // Otherwise, based on the rotate_left_right signal, perform either a standard shift
  // or a rotate operation. The left_right signal determines the direction.
  assign data_out = (shift_bits == 0) ? data_in :
                    (rotate_left_right ?
                        (left_right ?
                            // Left rotate: bits shifted out from the left end are inserted on the right.
                            {data_in[data_width-1:shift_bits], data_in[shift_bits-1:0]} :
                            // Right rotate: bits shifted out from the right end are inserted on the left.
                            {data_in[shift_bits-1:0], data_in[data_width-1:shift_bits]}
                        ) :
                        (left_right ? (data_in << shift_bits) : (data_in >> shift_bits))
                    );

endmodule