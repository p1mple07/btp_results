module barrel_shifter (
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input left_right,
    input rotate_left_right,
    output [data_width-1:0] data_out
);

parameter data_width = 16;
parameter shift_bits_width = 4;

always @(*) begin
    if (rotate_left_right) begin
        data_out = rotate_left_right ? (data_in << shift_bits) : (data_in >> shift_bits);
    end else begin
        data_out = left_right ? (data_in << shift_bits) : (data_in >> shift_bits);
    end
end

endmodule
