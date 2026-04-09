module barrel_shifter(input [(parameter data_width - 1):0] data_in, input [(parameter shift_bits_width - 1):0] shift_bits, input rotate_left_right, input left_right, output [(parameter data_width - 1):0] data_out);
  parameter data_width = 16;
  parameter shift_bits_width = 4;
  integer shift_amount;
  integer rotate_amount;
  
  assign shift_amount = shift_bits;
  assign rotate_amount = shift_bits;
  
  case ({rotate_left_right, left_right})
    // Rotate left
    1, 1:
      data_out = (data_in << rotate_amount) | (data_in >> (data_width - rotate_amount));
      break;
    // Rotate right
    0, 1:
      data_out = (data_in >> rotate_amount) | (data_in << (data_width - rotate_amount));
      break;
    // Shift left
    1, 0:
      data_out = data_in << rotate_amount;
      break;
    // Shift right
    0, 0:
      data_out = data_in >> rotate_amount;
      break;
  endcase
endmodule