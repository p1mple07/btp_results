function [7:0] expected_output(input [7:0] data_in, input [2:0] shift_bits, input left_right);
  begin
    if (left_right)  // Left shift
      expected_output = (data_in << shift_bits) & 8'hFF; // Mask to 8 bits
    else  // Right shift
      expected_output = (data_in >> shift_bits) & 8'hFF; // Mask to 8 bits
  end
endfunction