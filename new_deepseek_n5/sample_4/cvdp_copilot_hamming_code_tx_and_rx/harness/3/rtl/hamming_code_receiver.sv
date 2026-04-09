module hamming_code_receiver(
    input [7:0] data_in,
    output [3:0] data_out
);

    // Syndrome computation
    reg c1, c2, c3;

    c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];

    // Error correction
    reg error_pos;
    if (c1 & c2 & c3) error_pos = 7;
    else if (c1 & c3) error_pos = 6;
    else if (c1) error_pos = 5;
    else if (c2 & c3) error_pos = 4;
    else if (c2) error_pos = 3;
    else if (c3) error_pos = 2;
    else error_pos = 1;

    // Correct data bits
    data_out[3] = data_in[3] ^ (error_pos & 8);
    data_out[2] = data_in[2] ^ (error_pos & 4);
    data_out[1] = data_in[1] ^ (error_pos & 2);
    data_out[0] = data_in[0] ^ (error_pos & 1);

endmodule