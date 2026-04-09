module hamming_code_tx_for_4bit(
    input [3:0] data_in,
    output reg [7:0] data_out
);

    // Redundant bit
    assign data_out[0] = 0;

    // Parity bits
    wire parity1, parity2, parity3;

    // Calculate parity bits
    assign parity1 = data_in[0] ^ data_in[1] ^ data_in[3];
    assign parity2 = data_in[0] ^ data_in[2] ^ data_in[3];
    assign parity3 = data_in[1] ^ data_in[2] ^ data_in[3];

    // Assign parity bits to their respective positions
    assign data_out[1] = parity1;
    assign data_out[2] = parity2;
    assign data_out[4] = parity3;

    // Preserve the order of input data bits
    assign data_out[3] = data_in[0];
    assign data_out[5] = data_in[1];
    assign data_out[6] = data_in[2];
    assign data_out[7] = data_in[3];

endmodule