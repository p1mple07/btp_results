module barrel_shifter(input [(data_width - 1):0] data_in, input [shift_bits_width - 1:0] shift_bits, input left_right, input rotate_left_right, output [(data_width - 1):0] data_out);
    assign if (shift_bits == 0) then
        data_out = data_in;
    else
        if (left_right) then
            if (rotate_left_right) then
                // Left rotate
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
            else
                // Left shift
                data_out = data_in << shift_bits;
        else
            if (rotate_left_right) then
                // Right rotate
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
            else
                // Right shift
                data_out = data_in >> shift_bits;
    endmodule