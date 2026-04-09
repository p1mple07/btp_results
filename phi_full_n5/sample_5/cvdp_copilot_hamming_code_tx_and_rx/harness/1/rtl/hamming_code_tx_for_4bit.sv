module hamming_code_tx_for_4bit(
    input [3:0] data_in,
    output reg [7:0] data_out
);

    // Fixed redundant bit
    assign data_out[0] = 0;

    // Calculate parity bits
    wire c1, c2, c3;

    assign c1 = data_in[0] ^ data_in[1] ^ data_in[3];
    assign c2 = data_in[0] ^ data_in[2] ^ data_in[3];
    assign c3 = data_in[1] ^ data_in[2] ^ data_in[3];

    // Assign parity bits and data bits to output
    assign data_out[1] = c1;
    assign data_out[2] = c2;
    assign data_out[4] = c3;
    assign data_out[3] = data_in[0];
    assign data_out[5] = data_in[1];
    assign data_out[6] = data_in[2];
    assign data_out[7] = data_in[3];

endmodule
