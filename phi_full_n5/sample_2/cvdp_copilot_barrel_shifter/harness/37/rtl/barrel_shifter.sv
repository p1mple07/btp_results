module barrel_shifter #(parameter DATA_WIDTH = 16, parameter SHIFT_BITS_WIDTH = 4) (
    input [DATA_WIDTH-1:0] data_in,
    input [SHIFT_BITS_WIDTH-1:0] shift_bits,
    input rotate_left_right,
    input left_right,
    output reg [(DATA_WIDTH-1):0] data_out
);

    always @(data_in, shift_bits, rotate_left_right, left_right) begin
        if (rotate_left_right) begin
            if (left_right) begin
                data_out = {shift_bits, data_in[(DATA_WIDTH-shift_bits-1):0]};
            end else begin
                data_out = {data_in[(shift_bits):(DATA_WIDTH-1)], (DATA_WIDTH-shift_bits-1) };
            end
        end else begin
            if (left_right) begin
                data_out = {data_in[(DATA_WIDTH-shift_bits-1):0], data_in[(DATA_WIDTH-shift_bits):DATA_WIDTH-1]};
            end else begin
                data_out = {data_in[(shift_bits):(DATA_WIDTH-shift_bits-1)], data_in[0]};
            end
        end
    end
endmodule