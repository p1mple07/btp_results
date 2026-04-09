module barrel_shifter(input [(data_width-1):0] data_in, input [shift_bits_width-1:0] shift_bits, input left_right, input rotate_left_right, output [(data_width-1):0] data_out);
  parameter data_width = 16;
  parameter shift_bits_width = 4;
  parameter shift_bits = 0;
  
  if (rotate_left_right) 
    if (left_right) 
      data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
    else 
      data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
  else 
    if (left_right) 
      data_out = data_in << shift_bits;
    else 
      data_out = data_in >> shift_bits;
  endif
endmodule