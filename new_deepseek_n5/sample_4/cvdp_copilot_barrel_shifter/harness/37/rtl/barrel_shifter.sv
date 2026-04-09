module barrel_shifter(input [(data_width-1):0] data_in, input [shift_bits_width-1:0] shift_bits, input rotate_left_right, input left_right, output [(data_width-1):0] data_out);
  parameter data_width = 16;
  parameter shift_bits_width = 4;
  
  function barrel_shifter_t(data_in [(data_width-1):0], shift_bits [shift_bits_width-1:0], rotate, direction);
    if (shift_bits == 0) begin
      return data_in;
    end
    if (rotate) begin
      if (direction) begin
        // Left rotate
        return (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
      end
      else begin
        // Right rotate
        return (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
      end
    end
    else begin
      // Standard shift
      if (direction) begin
        return data_in << shift_bits;
      end
      else begin
        return data_in >> shift_bits;
      end
    end
  end
  
  data_out = barrel_shifter_t(data_in, shift_bits, rotate_left_right, left_right);
endmodule