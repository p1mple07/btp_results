module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4,
    parameter mode_width = 3
)(
    input [data_width-1:0] data_in,
    input [data_width-1:0] mask,
    input [mode_width-1:0] mode,
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    output reg [data_width-1:0] data_out,
    output reg error
);

always @(*) begin
    case (mode)
        000: begin
            if (left_right)
                data_out = data_in << shift_bits;
            else
                data_out = data_in >> shift_bits;
            error = 0;
        001: begin
            if (left_right)
                data_out = data_in << shift_bits;
            else if (arithmetic_shift)
                data_out = $signed(data_in) >>> shift_bits;
            else
                data_out = data_in >> shift_bits;
            error = 0;
        010: begin
            if (left_right)
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
            else
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
            error = 0;
        011: begin
            if (left_right)
                data_out = (data_in << shift_bits) & mask;
            else
                data_out = (data_in >> shift_bits) & mask;
            error = 0;
        100: begin
            if (left_right)
                data_out = (data_in << shift_bits) ^ mask;
            else
                data_out = (data_in >> shift_bits) ^ mask;
            error = 0;
        endcase
        default: begin
            data_out = 0;
            error = 1;
        end
    endcase
end

endmodule