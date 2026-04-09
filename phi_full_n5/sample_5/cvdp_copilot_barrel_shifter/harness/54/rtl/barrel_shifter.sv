
module barrel_shifter #(
    parameter data_width = 16,      // Change data_width to 16
    parameter shift_bits_width = 4  // Update shift_bits_width to handle shifts for 16-bit width
)(
    input [data_width-1:0] data_in,
    input [2:0] mode,                 // 3-bit mode signal
    input [data_width-1:0] shift_bits,
    input left_right,                 // 1: left shift, 0: right shift
    input rotate_left_right,          // 1: rotate, 0: shift
    input arithmetic_shift,           // 1: arithmetic shift, 0: logical shift
    input [data_width-1:0] mask,        // Customizable mask input
    output reg [data_width-1:0] data_out,
    output error                      // Error signal
);

always_comb begin
    error = 0; // Initialize error to 0
    if (mode != 3'b000 && mode != 3'b001 && mode != 3'b010 && mode != 3'b011 && mode != 3'b100) begin
        error = 1; // Set error to 1 for invalid mode
        data_out = 0; // Default to zero for invalid mode
    end
    else begin
        if (mode == 3'b000) begin
            if (rotate_left_right) begin
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); // Rotate left
            else
                data_out = (data_in << shift_bits) | (data_in >> shift_bits); // Rotate right
            error = 0;
        end else if (mode == 3'b001) begin
            data_out = $signed(data_in) >>> shift_bits; // Arithmetic right shift
            error = 0;
        end else if (mode == 3'b010) begin
            data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); // Rotate left
            error = 0;
        end else if (mode == 3'b011) begin
            if (left_right) begin
                data_out = (data_in << shift_bits) & mask; // Masked left shift
            else begin
                data_out = (data_in >> shift_bits) & mask; // Masked right shift
            end
            error = 0;
        end else if (mode == 3'b100) begin
            if (left_right) begin
                data_out = (data_in << shift_bits) ^ mask; // XOR after left shift
            else
                data_out = (data_in >> shift_bits) ^ mask; // XOR after right shift
            error = 0;
        end else begin
            error = 1; // Invalid mode
        end
    end
end

endmodule
