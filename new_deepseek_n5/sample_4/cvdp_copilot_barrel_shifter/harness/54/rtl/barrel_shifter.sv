module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4,
    parameter mode_width = 3
)(
    input [data_width-1:0] data_in,
    input [mode_width-1:0] mode,
    input [data_width-1:0] mask,
    input left_right,
    input rotate_left_right,
    input arithmetic_shift,
    output reg [data_width-1:0] data_out,
    output reg error
);

    // Set default error state
    always @(*) begin
        if (mode != 0 && mode != 1 && mode != 2 && mode != 3) begin
            error = 1;
            data_out = 0;
            return;
        end

        // Mode 000: Logical Shift
        if (mode == 0) begin
            if (left_right) begin
                data_out = data_in << shift_bits;
            else begin
                data_out = data_in >> shift_bits;
            end
        end

        // Mode 001: Arithmetic Shift
        else if (mode == 1) begin
            if (left_right) begin
                data_out = data_in << shift_bits;
            else begin
                data_out = $signed(data_in) >>> shift_bits;
            end
        end

        // Mode 010: Rotate
        else if (mode == 2) begin
            if (left_right) begin
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
            else begin
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
            end
        end

        // Mode 011: Masked Shift
        else if (mode == 3) begin
            if (left_right) begin
                data_out = (data_in << shift_bits) & mask;
            else begin
                data_out = (data_in >> shift_bits) & mask;
            end
        end

        // Mode 100: XOR with Mask
        else if (mode == 4) begin
            if (left_right) begin
                data_out = (data_in << shift_bits) ^ mask;
            else begin
                data_out = (data_in >> shift_bits) ^ mask;
            end
        end
    end
end

endmodule