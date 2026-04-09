module reverse_bits (
    input [31:0] num_in,
    output [31:0] num_out
);

initial
begin
    num_out[0] = num_in[31];
    num_out[1] = num_in[30];
    num_out[2] = num_in[29];
    num_out[3] = num_in[28];
    num_out[4] = num_in[27];
    num_out[5] = num_in[26];
    num_out[6] = num_in[25];
    num_out[7] = num_in[24];
    num_out[8] = num_in[23];
    num_out[9] = num_in[22];
    num_out[10] = num_in[21];
    num_out[11] = num_in[20];
    num_out[12] = num_in[19];
    num_out[13] = num_in[18];
    num_out[14] = num_in[17];
    num_out[15] = num_in[16];
end

endmodule
