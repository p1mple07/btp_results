module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [2:0] mode,
    input [data_width-1:0] shift_bits,
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    input [data_width-1:0] mask,
    output reg [data_width-1:0] data_out,
    output reg error
);

always @(*) begin
    if (mode == 3'b000) begin
        if (left_right)
            data_out = data_in << shift_bits;
        else
            data_out = data_in >> shift_bits;
    end else if (mode == 3'b001) begin
        if (left_right)
            data_out = $signed(data_in) >>> shift_bits;
        else
            data_out = $signed(data_in) << shift_bits;
    end else if (mode == 3'b010) begin
        if (left_right)
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
        else
            data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
    end else if (mode == 3'b011) begin
        if (left_right)
            data_out = (data_in << shift_bits) & mask;
        else
            data_out = (data_in >> shift_bits) & mask;
    end else if (mode == 3'b100) begin
        if (left_right)
            data_out = (data_in << shift_bits) ^ mask;
        else
            data_out = (data_in >> shift_bits) ^ mask;
    end else begin
        data_out = 0;
        error = 1;
    end
end

endmodule
 module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [2:0] mode,
    input [data_width-1:0] shift_bits,
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    input [data_width-1:0] mask,
    output reg [data_width-1:0] data_out,
    output reg error
);

always @(*) begin
    if (mode == 3'b000) begin
        if (left_right)
            data_out = data_in << shift_bits;
        else
            data_out = data_in >> shift_bits;
    end else if (mode == 3'b001) begin
        if (left_right)
            data_out = $signed(data_in) >>> shift_bits;
        else
            data_out = $signed(data_in) << shift_bits;
    end else if (mode == 3'b010) begin
        if (left_right)
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
        else
            data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
    end else if (mode == 3'b011) begin
        if (left_right)
            data_out = (data_in << shift_bits) & mask;
        else
            data_out = (data_in >> shift_bits) & mask;
    end else if (mode == 3'b100) begin
        if (left_right)
            data_out = (data_in << shift_bits) ^ mask;
        else
            data_out = (data_in >> shift_bits) ^ mask;
    end else begin
        data_out = 0;
        error = 1;
    end
end

endmodule