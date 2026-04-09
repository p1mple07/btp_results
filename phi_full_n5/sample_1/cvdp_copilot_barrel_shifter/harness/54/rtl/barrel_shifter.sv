module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,
    input mask,
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    output reg [data_width-1:0] data_out,
    output reg error
);

always @(*) begin
    if (mode == 3'b000) begin
        if (rotate_left_right) begin
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); // Rotate left
        end else if (left_right) begin
            data_out = data_in << shift_bits; // Logical left shift
        end else if (arithmetic_shift) begin
            data_out = $signed(data_in) >>> shift_bits; // Arithmetic right shift
        end else begin
            data_out = data_in >> shift_bits; // Logical right shift
        end
    end else if (mode == 3'b001) begin
        if (rotate_left_right) begin
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); // Rotate left
        end else if (left_right) begin
            data_out = $signed(data_in) >>> shift_bits; // Arithmetic left shift
        end else if (arithmetic_shift) begin
            data_out = $signed(data_in) >>> shift_bits; // Arithmetic right shift
        end else begin
            data_out = $signed(data_in) >>> shift_bits; // Arithmetic left shift
        end
    end else if (mode == 3'b010) begin
        if (left_right) begin
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); // Rotate left
        end else begin
            data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits)); // Rotate right
        end
    end else if (mode == 3'b011) begin
        if (left_right) begin
            data_out = (data_in << shift_bits) & mask; // Masked left shift
        end else if (arithmetic_shift) begin
            data_out = (data_in >>> shift_bits) & mask; // Masked arithmetic right shift
        end else begin
            data_out = (data_in >> shift_bits) & mask; // Masked right shift
        end
    end else if (mode == 3'b100) begin
        if (left_right) begin
            data_out = (data_in << shift_bits) ^ mask; // XOR after left shift
        end else begin
            data_out = (data_in >> shift_bits) ^ mask; // XOR after right shift
        end
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
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,
    input mask,
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    output reg [data_width-1:0] data_out,
    output reg error
);

always @(*) begin
    if (mode == 3'b000) begin
        if (rotate_left_right) begin
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); // Rotate left
        end else if (left_right) begin
            data_out = data_in << shift_bits; // Logical left shift
        end else if (arithmetic_shift) begin
            data_out = $signed(data_in) >>> shift_bits; // Arithmetic right shift
        end else begin
            data_out = data_in >> shift_bits; // Logical right shift
        end
    end else if (mode == 3'b001) begin
        if (rotate_left_right) begin
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); // Rotate left
        end else if (left_right) begin
            data_out = $signed(data_in) >>> shift_bits; // Arithmetic left shift
        end else if (arithmetic_shift) begin
            data_out = $signed(data_in) >>> shift_bits; // Arithmetic right shift
        end else begin
            data_out = $signed(data_in) >>> shift_bits; // Arithmetic left shift
        end
    end else if (mode == 3'b010) begin
        if (left_right) begin
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); // Rotate left
        end else begin
            data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits)); // Rotate right
        end
    end else if (mode == 3'b011) begin
        if (left_right) begin
            data_out = (data_in << shift_bits) & mask; // Masked left shift
        end else if (arithmetic_shift) begin
            data_out = (data_in >>> shift_bits) & mask; // Masked arithmetic right shift
        end else begin
            data_out = (data_in >> shift_bits) & mask; // Masked right shift
        end
    end else if (mode == 3'b100) begin
        if (left_right) begin
            data_out = (data_in << shift_bits) ^ mask; // XOR after left shift
        end else begin
            data_out = (data_in >> shift_bits) ^ mask; // XOR after right shift
        end
    end else begin
        data_out = 0;
        error = 1;
    end
end

endmodule