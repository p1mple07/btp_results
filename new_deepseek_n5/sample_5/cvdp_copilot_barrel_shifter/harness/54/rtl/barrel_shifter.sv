module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4,
    parameter mask_width = data_width  // Derived from data_width
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [mask_width-1:0] mask,  // Additional mask input for mode 011 and 100
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    input mode,
    output reg [data_width-1:0] data_out,
    output reg error
);

always @(*) begin
    if (mode == 000) begin
        // Logical shift
        if (left_right)
            data_out = data_in << shift_bits;
        else
            data_out = data_in >> shift_bits;
    else if (mode == 001) begin
        // Arithmetic shift with sign extension
        data_out = $signed(data_in) >>> shift_bits;
    else if (mode == 010) begin
        // Rotate
        if (left_right)
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
        else
            data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
    else if (mode == 011) begin
        // Masked shift
        if (left_right)
            data_out = (data_in << shift_bits) & mask;
        else
            data_out = (data_in >> shift_bits) & mask;
    else if (mode == 100) begin
        // XOR with shifted data and mask
        if (left_right)
            data_out = (data_in << shift_bits) ^ mask;
        else
            data_out = (data_in >> shift_bits) ^ mask;
    else begin
        // Invalid mode
        data_out = 0;
        error = 1;
    end
end

endmodule