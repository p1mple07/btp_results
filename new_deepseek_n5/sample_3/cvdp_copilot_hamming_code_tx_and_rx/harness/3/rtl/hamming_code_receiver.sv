module hamming_code_receiver(
    input [7:0] data_in,
    output [3:0] data_out
);
    // Syndrome bits calculation
    assign c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    assign c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    assign c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
    // Error position calculation
    assign error_pos = c1 << 2 | c2 << 1 | c3;
    // Data correction
    if (error_pos != 0) {
        data_in[error_pos] = ~data_in[error_pos];
    }
    // Output the corrected data bits
    assign data_out[0] = data_in[7];
    assign data_out[1] = data_in[6];
    assign data_out[2] = data_in[5];
    assign data_out[3] = data_in[3];
endmodule