module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input left_right,           // 1: left shift, 0: right shift
    input [2:0] mode,           // Operation mode:
                                // 000: Logical Shift
                                // 001: Arithmetic Shift (with sign extension for right shifts)
                                // 010: Rotate (circular shift)
                                // 011: Custom Mask-Based Shift
                                // 100: XOR with Shifted Data and Mask
    input [data_width-1:0] mask,// Mask input for custom operations (modes 011 and 100)
    output reg [data_width-1:0] data_out,
    output reg error            // 1 indicates an invalid mode
);

always @(*) begin
    error = 0;  // Default: no error
    case (mode)
        3'b000: begin // Logical Shift
            if (left_right)
                data_out = data_in << shift_bits;
            else
                data_out = data_in >> shift_bits;
        end
        3'b001: begin // Arithmetic Shift
            if (left_right)
                data_out = data_in << shift_bits;  // Left arithmetic shift is similar to logical
            else
                data_out = $signed(data_in) >>> shift_bits;  // Arithmetic right shift with sign extension
        end
        3'b010: begin // Rotate Operation (circular shift)
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
        default: begin // Invalid Mode: set output to zero and flag error
            data_out = {data_width{1'b0}};
            error = 1;
        end
    endcase
end

endmodule