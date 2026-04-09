module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    output reg [7:0] data_out,
    input shift_mode // new input
);

    always @(*) begin
        if (shift_mode == 0) begin
            if (left_right) begin
                data_out = data_in << shift_bits;
            end else begin
                data_out = data_in >> shift_bits;
            end
        end else begin
            if (left_right) begin
                // arithmetic right shift: replicate sign bit
                data_out = ((data_in >> shift_bits) << 1) | ((data_in >> shift_bits) & 1) << (signed_width - shift_bits);
            end else begin
                data_out = data_in >> shift_bits;
            end
        end
    end

endmodule
