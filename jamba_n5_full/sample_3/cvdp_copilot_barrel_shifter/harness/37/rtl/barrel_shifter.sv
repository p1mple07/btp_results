`timescale 1ns / 1ps
module barrel_shifter_8bit(
    input [7:0] data_in,
    input [2:0] shift_bits,
    input left_right,
    input rotate_left_right,
    output [7:0] data_out
);

parameter integer data_width = 16;
parameter integer shift_bits_width = 4;

always @(*) begin
    if (rotate_left_right) begin
        data_out = data_in << shift_bits_width;
    end else begin
        if (left_right) begin
            data_out = data_in >> shift_bits_width;
        end else begin
            data_out = data_in >> (7 - shift_bits_width);
        end
    end
end

endmodule
