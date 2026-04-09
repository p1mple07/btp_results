module barrel_shifter_8bit_rotatable (
    input [7:0] data_in,
    input [2:0] shift_bits,
    input left_right,
    input rotate_left_right,
    output [7:0] data_out
);

localparam data_width = 16;
localparam shift_bits_width = 4;

always @(*) begin
    if (rotate_left_right) begin
        data_out[data_width-1] = data_in[data_width-2];
        for (i=1; i<data_width; i++) data_out[i] = data_in[i-1];
        data_out[0] = data_in[data_width-1];
    end else begin
        data_out[0] = data_in[data_width-1];
        for (i=1; i<data_width; i++) data_out[i] = data_in[i-1];
    end
end

endmodule
