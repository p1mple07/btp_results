module hamming_code_receiver(
    input [7:0] data_in,
    output [3:0] data_out
);

    // Syndrome bits
    reg c1, c2, c3;

    // Calculate syndrome bits
    c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
    c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];

    // Error correction
    reg error_pos;
    error_pos = c1 << 2 | c2 << 1 | c3;

    // If no error, output data_in[3:0]
    // Else, flip the bit at error_pos
    if (error_pos != 0) begin
        data_out = data_in;
        data_out[error_pos] = ~data_out[error_pos];
    end else begin
        data_out = data_in[3:0];
    end

endmodule