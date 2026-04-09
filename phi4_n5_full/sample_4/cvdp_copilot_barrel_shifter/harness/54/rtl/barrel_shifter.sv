module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input left_right,  // 1: left shift, 0: right shift
    input [2:0] mode,  // Mode signal:
                      // 000: Logical Shift
                      // 001: Arithmetic Shift (with sign extension for right shifts)
                      // 010: Rotate (circular shift)
                      // 011: Custom Mask-Based Shift
                      // 100: XOR with Shifted Data and Mask
    input [data_width-1:0] mask, // Mask input for custom operations
    output reg [data_width-1:0] data_out,
    output reg error  // Error flag: 1 if mode is invalid
);

always @(*) begin
    // Default assignments
    data_out = {data_width{1'b0}};
    error = 1'b0;
    
    case (mode)
        3'b000: begin
            // Logical Shift
            if (left_right)
                data_out = data_in << shift_bits;
            else
                data_out = data_in >> shift_bits;
        end
        3'b001: begin
            // Arithmetic Shift: sign extension for right shifts
            if (left_right)
                data_out = data_in << shift_bits;
            else
                data_out = $signed(data_in) >>> shift_bits;
        end
        3'b010: begin
            // Rotate: Circular shift
            if (left_right)
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
            else
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
        end
        3'b011: begin
            // Custom Mask-Based Shift: apply mask to shifted data
            if (left_right)
                data_out = (data_in << shift_bits) & mask;
            else
                data_out = (data_in >> shift_bits) & mask;
        end
        3'b100: begin
            // XOR with Shifted Data and Mask
            if (left_right)
                data_out = (data_in << shift_bits) ^ mask;
            else
                data_out = (data_in >> shift_bits) ^ mask;
        end
        default: begin
            // Invalid mode: set error flag and default output to zero
            error = 1'b1;
            data_out = {data_width{1'b0}};
        end
    endcase
end

endmodule