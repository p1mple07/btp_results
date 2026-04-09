module barrel_shifter #(
    parameter data_width = 16,      // Width of the data bus
    parameter shift_bits_width = 4  // Width of the shift operand
)(
    input [data_width-1:0] data_in,
    input [shift_bits-1:0] shift_bits,
    input left_right,               // 1 = left shift, 0 = right shift
    input rotate_left_right,        // 1 = rotate, 0 = shift
    input arithmetic_shift,         // 1 = arithmetic shift, 0 = logical shift
    output reg [data_width-1:0] data_out
);

reg [2:0] mode;
reg error;

always @(*) begin
    if (!mode.get())
        mode = 0;
    else
        mode = mode.get();

    error = (mode != 0 && mode != 1 && mode != 2 && mode != 3 && mode != 4) ? 1 : 0;

    case (mode)
      // 000 – Logical Shift (Left or Right)
      case (0) {
        data_out = (data_width-1 downto 0) << shift_bits;
        data_out[shift_bits-1] = data_in[shift_bits-1];
        data_out[data_width-1] = 0;
      }

      // 001 – Arithmetic Shift (Sign‑Extend Right Shifts)
      case (1) {
        if (arithmetic_shift)
            data_out = $signed(data_in) >>> shift_bits;
        else
            data_out = data_in >>> shift_bits;
      }

      // 010 – Rotate (Circular Shift)
      case (2) {
        if (left_right)
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
        else
            data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
      }

      // 011 – Custom Mask‑Based Shift
      case (3) {
        if (rotate_left_right) {
          data_out = (data_in << shift_bits) & mask | (data_in >> shift_bits) & mask;
        } else {
          data_out = data_in >> shift_bits;
        }
      }

      // 100 – XOR with Shifted Data and Mask
      case (4) {
        data_out = (data_in << shift_bits) ^ mask;
        data_out = (data_in >> shift_bits) ^ mask;
      }

      default {
        data_out = 0;
        error = 1;
      }
    endcase
endalways

endmodule
