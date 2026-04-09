module hamming_code_receiver(
    input data_in[7:0],
    output data_out[3:0]
);

    // Syndrome bits
    local bit c1, c2, c3;

    // Calculate syndrome bits
    c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];

    // Combine syndrome bits
    local bit error_pos = (c1 << 2) | (c2 << 1) | c3;

    // If no error, output data_in[7:3]
    if (error_pos == 0)
        data_out[3:0] = data_in[7:3];
    else
        // Invert the bit at the error position
        data_in[error_pos + 0] = ~data_in[error_pos + 0];
        data_out[3:0] = data_in[7:3];
    end

endmodule