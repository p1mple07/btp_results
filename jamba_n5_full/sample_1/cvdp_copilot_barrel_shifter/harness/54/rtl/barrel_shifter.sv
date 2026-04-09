module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    input mask,
    input mode [2:0],
    output reg [data_width-1:0] data_out,
    output reg error
);

reg [data_width-1:0] data_out_temp;

always @(*) begin
    if (mode == 0) begin
        // Logical Shift
        data_out_temp = {data_in[data_width-1:0], data_in[(data_width-1)-shift_bits:0]};
        data_out = data_out_temp;
    end
    else if (mode == 1) begin
        // Arithmetic Shift
        if (arithmetic_shift)
            data_out_temp = $signed(data_in) >>> shift_bits;
        else
            data_out_temp = data_in >> shift_bits;
        data_out = data_out_temp;
    end
    else if (mode == 2) begin
        // Rotate
        data_out_temp = rotate_left_right ? 
            (data_in << shift_bits) | (data_in >> (data_width - shift_bits)) :
            (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
        data_out = data_out_temp;
    end
    else if (mode == 3) begin
        // Custom Mask-Based Shift
        data_out_temp = (data_in << shift_bits) & mask;
        data_out = data_out_temp;
    end
    else if (mode == 4) begin
        // XOR after Left Shift
        data_out_temp = (data_in << shift_bits) ^ mask;
        data_out = data_out_temp;
    end
    else if (mode == 5) begin
        // XOR after Right Shift
        data_out_temp = (data_in >> shift_bits) ^ mask;
        data_out = data_out_temp;
    end
    else begin
        data_out_temp = 0;
        error = 1;
    end
end

assign data_out = data_out_temp;
assign error = !$signed(mode);

endmodule
