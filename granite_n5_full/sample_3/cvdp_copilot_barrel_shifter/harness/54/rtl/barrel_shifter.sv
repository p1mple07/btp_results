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
    output reg error
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

        // Check for invalid mode and set error accordingly
        if (mode[2:0] == 3'b000 || mode[2:0] > 3'b100) begin
            data_out = 0;
            error = 1;
        end else
            error = 0;
    end
end

endmodule