module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4,
    parameter mode_size = 3,
    parameter mask = 32'hFFFF_FFF0
) (
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input left_right,               // 1: left shift, 0: right shift
    input rotate_left_right,        // 1: rotate, 0: shift
    input arithmetic_shift,         // 1: arithmetic shift, 0: logical shift
    output reg [data_width-1:0] data_out
);

logic [data_width-1:0] mask;

always @(*) begin
    case (mode)
        0: begin
            // Logical shift
            data_out = data_in << shift_bits;
            if (arithmetic_shift) {
                data_out = $signed(data_in) >>> shift_bits;
            }
            end
        end
        1: begin
            // Arithmetic shift with sign extension
            data_out = $signed(data_in) >>> shift_bits;
        end
        2: begin
            // Rotate
            if (left_right) {
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
            } else {
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
            }
        end
        3: begin
            // Custom mask-based shift
            if (rotate_left_right) begin
                data_out = (data_in << shift_bits) & mask;
            } else {
                data_out = (data_in >> shift_bits) & mask;
            }
        end
        4: begin
            // XOR with shifted data and mask
            data_out = (data_in << shift_bits) ^ mask;
            end
        5: begin
            // XOR after left or right shift
            data_out = (data_in << shift_bits) ^ mask;
            data_out = (data_in >> shift_bits) ^ mask;
        end
        6: begin
            // Invalid mode – default to zero output and error flag
            data_out = 0;
            error = 1;
        end
        default:
            data_out = 0;
            error = 1;
    endcase
end

endmodule
