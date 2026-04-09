module barrel_shifter #(parameter DATA_WIDTH = 16, parameter SHIFT_BITS_WIDTH = 4)
(input [DATA_WIDTH-1:0]data_in, input [2:0] shift_bits, input rotate_left_right, input left_right, output [DATA_WIDTH-1:0]data_out);

assign shift_bits = shift_bits_WIDTH;

if (rotate_left_right) begin
    if (left_right) begin
        data_out = data_in << shift_bits;
    end else begin
        data_out = data_in >> shift_bits;
    end
else begin
    if (left_right) begin
        data_out = (data_in << shift_bits) + (data_in >> (DATA_WIDTH - shift_bits_WIDTH));
    end else begin
        data_out = (data_in >> shift_bits) + (data_in << (DATA_WIDTH - shift_bits_WIDTH));
    end
end

endmodule