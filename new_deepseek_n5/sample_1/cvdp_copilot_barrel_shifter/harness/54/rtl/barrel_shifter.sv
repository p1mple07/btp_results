module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4,
    parameter mode_width = 3  // Mode is 3 bits
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    input [data_width-1:0] mask,  // Mask input for mode 011
    input mode,
    output reg [data_width-1:0] data_out,
    output reg error
);

always @(*) begin
    if (mode != 0 && mode != 1 && mode != 2 && mode != 3 && mode != 4 && mode != 5) begin
        data_out = 0;
        error = 1;
        return;
    end

    case (mode)
        000: begin
            if (left_right)
                data_out = data_in << shift_bits;
            else
                data_out = data_in >> shift_bits;
        end
        001: begin
            if (left_right)
                data_out = data_in << shift_bits;
            else begin
                data_out = $signed(data_in) >>> shift_bits;
                if (data_out < 0) data_out = $unsigned(data_out);
            end
        end
        010: begin
            if (left_right)
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
            else
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
        end
        011: begin
            if (left_right)
                data_out = (data_in << shift_bits) & mask;
            else
                data_out = (data_in >> shift_bits) & mask;
        end
        100: begin
            if (left_right)
                data_out = (data_in << shift_bits) ^ mask;
            else
                data_out = (data_in >> shift_bits) ^ mask;
        end
        default:
            data_out = 0;
            error = 1;
    endcase
end

endmodule