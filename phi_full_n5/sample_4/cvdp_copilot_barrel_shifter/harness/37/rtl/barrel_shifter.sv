module barrel_shifter #(parameter data_width = 16, parameter shift_bits_width = 4) #(parameter W = data_width)
(input [W-1:0]data_in,
 input [2:0] shift_bits,
 input rotate_left_right,
 input left_right,
 output reg [W-1:0]data_out);

always @(data_in, shift_bits, left_right, rotate_left_right) begin
    if (rotate_left_right) begin
        if (left_right) begin
            data_out = {data_in[W-2:0], data_in[W-shift_bits_width:W-2]};
        end else begin
            data_out = {data_in[0:W-shift_bits_width], data_in[W-1:1]};
        end
    end else begin
        if (left_right) begin
            data_out = {data_in[shift_bits_width-1:0], data_in[W-shift_bits_width:W-1]};
        end else begin
            data_out = {data_in[W-shift_bits_width-1:0], data_in[0:shift_bits_width-1]};
        end
    end
end
endmodule
 module barrel_shifter #(parameter data_width = 16, parameter shift_bits_width = 4) #(parameter W = data_width)
(input [W-1:0]data_in,
 input [2:0] shift_bits,
 input rotate_left_right,
 input left_right,
 output reg [W-1:0]data_out);

always @(data_in, shift_bits, left_right, rotate_left_right) begin
    if (rotate_left_right) begin
        if (left_right) begin
            data_out = {data_in[W-shift_bits_width-1:0], data_in[W-1:1]};
        end else begin
            data_out = {data_in[shift_bits_width-1:0], data_in[0:shift_bits_width-1]};
        end
    end else begin
        if (left_right) begin
            data_out = {data_in[shift_bits_width-1:0], data_in[W-shift_bits_width:W-1]};
        end else begin
            data_out = {data_in[0:shift_bits_width-1], data_in[W-shift_bits_width:W-1]};
        end
    end
end
endmodule