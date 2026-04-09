module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input left_right,
    input [1:0] shift_mode,  // Determines shift operation type
    output reg [7:0] data_out
);

module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input left_right,
    input [1:0] shift_mode,
    output reg [7:0] data_out
);

    always @(*) begin
        if (left_right) {
            if (shift_mode) {  // Arithmetic Left Shift
                sign_bit = (data_in >> 7) & 1;  // Extract sign bit (MSB)
                sign_mask = (sign_bit << 7);       // Create mask to replicate sign bit
                data_out = (data_in << shift_bits) & 8'hFF;  // Perform shift and mask
            } else {  // Logical Left Shift
                data_out = (data_in << shift_bits) & 8'hFF;
            }
        } else {  // Right Shift
            if (shift_mode) {  // Arithmetic Right Shift
                sign_bit = (data_in >> 7) & 1;  // Extract sign bit
                sign_mask = sign_bit << 7;        // Extend sign bit to 8 bits
                // Shift and retain sign extension
                data_out = ((((data_in & sign_mask) >> shift_bits) | (sign_bit << (8 - shift_bits))) & 8'hFF;
            } else {  // Logical Right Shift
                data_out = (data_in >> shift_bits) & 8'hFF;
            }
        }
    end

endmodule