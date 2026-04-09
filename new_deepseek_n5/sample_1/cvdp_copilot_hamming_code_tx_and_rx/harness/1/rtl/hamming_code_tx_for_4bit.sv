module hamming_code_tx_for_4bit(
    input data_in[3:0],
    output data_out[7:0]
);
    data_out[0] = 0;
    data_out[1] = data_in[0] ^ data_in[1] ^ data_in[3];
    data_out[2] = data_in[0] ^ data_in[2] ^ data_in[3];
    data_out[4] = data_in[1] ^ data_in[2] ^ data_in[3];
    data_out[3] = data_in[0];
    data_out[5] = data_in[1];
    data_out[6] = data_in[2];
    data_out[7] = data_in[3];
endmodule