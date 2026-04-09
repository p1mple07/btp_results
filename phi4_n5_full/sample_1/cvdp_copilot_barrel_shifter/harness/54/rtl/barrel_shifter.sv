module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,
    input [data_width-1:0] mask,
    input left_right,         // 1: left shift/rotate, 0: right shift/rotate
    output reg [data_width-1:0] data_out,
    output reg error          // 1 indicates an invalid mode
);

always @(*) begin
    error = 0;
    case (mode)
        3'b000: begin // Logical Shift
            if (left_right)
                data_out = data_in << shift_bits;
            else
                data_out = data_in >> shift_bits;
        end
        3'b001: begin // Arithmetic Shift (sign extension for right shifts)
            if (left_right)
                data_out = data_in << shift_bits;
            else
                data_out = $signed(data_in) >>> shift_bits;
        end
        3'b010: begin // Rotate (circular shift)
            if (left_right)
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
            else
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
        end
        3'b011: begin // Custom Mask-Based Shift
            if (left_right)
                data_out = (data_in << shift_bits) & mask;
            else
                data_out = (data_in >> shift_bits) & mask;
        end
        3'b100: begin // XOR with Shifted Data and Mask
            if (left_right)
                data_out = (data_in << shift_bits) ^ mask;
            else
                data_out = (data_in >> shift_bits) ^ mask;
        end
        default: begin
            error = 1;
            data_out = {data_width{1'b0}};
        end
    endcase
end

endmodule