module barrel_shifter #(
    parameter data_width = 16,      // Change data_width to 16
    parameter shift_bits_width = 4  // Update shift_bits_width to handle shifts for 16-bit width
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input left_right,               // 1: left shift, 0: right shift
    input rotate_left_right,        // 1: rotate, 0: shift
    input arithmetic_shift,         // 1: arithmetic shift, 0: logical shift
    input [2:0] mode,               // 3-bit mode
    input [data_width-1:0] mask,    // custom mask for mode 011
    output reg [data_width-1:0] data_out,
    output reg [data_width-1:0] data_temp,
    output reg error
);

// Initialize error and data_out on reset (optional)
always_comb begin
    if (!$readmemh("mode")) begin
        data_out <= 0;
        error <= 1;
        return;
    end
end

case (mode)
    2'b000: begin
        // logical shift
        data_out = data_in >> shift_bits;
    end
    2'b001: begin
        // arithmetic shift with sign extension
        data_out = $signed(data_in) >>> shift_bits;
    end
    2'b010: begin
        // rotate
        data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
    end
    2'b011: begin
        // custom mask-based shift
        data_out = (data_in << shift_bits) & mask;
    end
    2'b100: begin
        // XOR after left shift
        data_out = (data_in << shift_bits) ^ mask;
    end
    default:
        data_out <= 0;
        error <= 1;
        return;
endcase

endmodule
