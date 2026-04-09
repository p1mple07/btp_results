module reverse_bits (
    input [31:0] num_in,
    output [31:0] num_out
);

    // Reverse the 32-bit input number
    assign num_out[0] = num_in[31];
    assign num_out[1] = num_in[30];
    assign num_out[2] = num_in[29];
    assign num_out[3] = num_in[28];
    assign num_out[4] = num_in[27];
    assign num_out[5] = num_in[26];
    assign num_out[6] = num_in[25];
    assign num_out[7] = num_in[24];
    assign num_out[8] = num_in[23];
    assign num_out[9] = num_in[22];
    assign num_out[10] = num_in[21];
    assign num_out[11] = num_in[20];
    assign num_out[12] = num_in[19];
    assign num_out[13] = num_in[18];
    assign num_out[14] = num_in[17];
    assign num_out[15] = num_in[16];
    assign num_out[16] = num_in[15];
    assign num_out[17] = num_in[14];
    assign num_out[18] = num_in[13];
    assign num_out[19] = num_in[12];
    assign num_out[20] = num_in[11];
    assign num_out[21] = num_in[10];
    assign num_out[22] = num_in[9];
    assign num_out[23] = num_in[8];
    assign num_out[24] = num_in[7];
    assign num_out[25] = num_in[6];
    assign num_out[26] = num_in[5];
    assign num_out[27] = num_in[4];
    assign num_out[28] = num_in[3];
    assign num_out[29] = num_in[2];
    assign num_out[30] = num_in[1];
    assign num_out[31] = num_in[0];

endmodule
