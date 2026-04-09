module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input left_right,
    input shift_mode,
    output reg [7:0] data_out
);

    always @(*) begin
        if (left_right) begin
            if (shift_mode) begin
                // Arithmetic shifts
                if (1) begin
                    // Arithmetic left shift
                    data_out = (data_in << shift_bits) & 8'hFF;
                end else begin
                    // Arithmetic right shift
                    sign_bit = (data_in >> 7) & 1;
                    shifted_data = (data_in >> shift_bits);
                    sign_mask = (sign_bit << (7 - shift_bits)) & 0xFF;
                    data_out = (shifted_data | sign_mask);
                end
            end else begin
                // Logical shifts
                data_out = (data_in << shift_bits) & 8'hFF;
            end
        end else begin
            if (shift_mode) begin
                // Arithmetic shifts
                if (1) begin
                    // Arithmetic left shift
                    data_out = (data_in << shift_bits) & 8'hFF;
                end else begin
                    // Arithmetic right shift
                    sign_bit = (data_in >> 7) & 1;
                    shifted_data = (data_in >> shift_bits);
                    sign_mask = (sign_bit << (7 - shift_bits)) & 0xFF;
                    data_out = (shifted_data | sign_mask);
                end
            end else begin
                // Logical shifts
                data_out = (data_in >> shift_bits) & 8'hFF;
            end
        end
    end

endmodule