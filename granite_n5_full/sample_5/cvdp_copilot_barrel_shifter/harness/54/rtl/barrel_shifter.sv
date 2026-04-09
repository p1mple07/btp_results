module barrel_shifter #(
    parameter data_width = 16,      // Change data_width to 16
    parameter shift_bits_width = 4  // Update shift_bits_width to handle shifts for 16-bit width
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input left_right,               // 1: left shift, 0: right shift
    input rotate_left_right,        // 1: rotate, 0: shift
    input arithmetic_shift,         // 1: arithmetic shift, 0: logical shift
    output reg [data_width-1:0] data_out,
    output reg error                    // 1: invalid mode, 0: valid mode
);

always @(*) begin
    if (rotate_left_right) begin
        // Rotation logic
        if (left_right)
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); // Rotate left
        else
            data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits)); // Rotate right
    end else begin
        // Shift logic
        if (left_right)
            data_out = data_in << shift_bits;  // Left shift
        else if (arithmetic_shift)
            // Arithmetic right shift: explicitly sign-extend data_in to ensure the MSB (sign bit) is preserved
            data_out = $signed(data_in) >>> shift_bits;
        else
            data_out = data_in >> shift_bits;  // Logical right shift

        if (shift_bits[0] == 1 &&!arithmetic_shift) begin
            // Handle negative values
            // This assumes that the sign bit is shifted out during logical shift operations
            if (!left_right)
                data_out = ~data_out + 1; // Negate the value and add 1
            else
                data_out = -data_out;     // Multiply by -1
        end
    end

    // Check for invalid mode
    if (mode > 3 || mode < 0) begin
        data_out = 0;
        error = 1;
    end else
        error = 0;
end

endmodule