module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    input       shift_mode,   // 0 for logical, 1 for arithmetic
    output reg [7:0] data_out
);

    always @(*) begin
        if (left_right) begin
            if (shift_mode == 0) begin
                data_out = data_in << shift_bits;
            end else begin
                data_out = data_in >> shift_bits;
            end
        end else begin
            if (shift_mode == 0) begin
                data_out = data_in >> shift_bits;
            end else begin
                data_out = data_in << shift_bits;
            end
        end
    end

endmodule
