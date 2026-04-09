module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] shift_bits,
    input        left_right,
    input  shift_mode,
    output reg [7:0] data_out
);

    always @(*) begin
        if (shift_mode == 0) begin
            if (left_right) data_out = data_in << shift_bits;
            else data_out = data_in >> shift_bits;
        end else begin
            if (left_right) data_out = data_in >> shift_bits;
            else data_out = data_in << shift_bits;
        end
    end

endmodule
