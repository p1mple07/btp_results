module barrel_shifter_8bit (
    input [7:0] data_in,
    input [2:0] shift_bits,
    input left_right,
    output [7:0] data_out
);

    assign data_out = (left_right) ? 
        (shift_bits == 3'b000 : data_in) 
        : 
        (left_right && (shift_bits == 3'b001)) ? 
            ({data_in[7 - (shift_bits - 0)] : 8'b0} << 1) 
        : 
        (left_right && (shift_bits == 3'b010)) ? 
            ({data_in[7 - (shift_bits - 0)] : 8'b0} >> 1) 
        : 
        (left_right && (shift_bits == 3'b011)) ? 
            ({data_in[7 - (shift_bits - 0)] : 8'b0} >> 1) 
        : 
        (left_right && (shift_bits == 3'b100)) ? 
            ({data_in[7 - (shift_bits - 0)] : 8'b0} << 1) 
        : 
        (left_right && (shift_bits == 3'b101)) ? 
            ({data_in[7 - (shift_bits - 0)] : 8'b0} << 1) 
        : 
        (left_right && (shift_bits == 3'b110)) ? 
            ({data_in[7 - (shift_bits - 0)] : 8'b0} << 1) 
        : data_in;

endmodule
