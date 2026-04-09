module barrel_shifter(input [(parameter data_width)-1:0] data_in, input [(parameter shift_bits_width)-1:0] shift_bits, input [1:0] left_right, input [2:1] rotate_left_right, output [(parameter data_width)-1:0] data_out);
  parameter data_width = 16;
  parameter shift_bits_width = 4;
  integer shift_bits;
  integer rotate_left_right;
  integer left_right;
  
  if (shift_bits == 0) begin
    data_out = data_in;
  else if (rotate_left_right == 1) begin
    if (left_right == 1) begin
      data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
    else begin
      data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
    end
  else begin
    if (left_right == 1) begin
      data_out = data_in << shift_bits;
    else begin
      data_out = data_in >> shift_bits;
    end
  end
endmodule