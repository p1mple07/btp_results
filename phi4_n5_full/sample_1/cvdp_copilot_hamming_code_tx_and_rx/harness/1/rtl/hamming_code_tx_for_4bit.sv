module hamming_code_tx_for_4bit(
    input  logic [3:0] data_in,
    output logic [7:0] data_out
);
    // In this design, data_out[7:1] represent the 7-bit Hamming code (3 parity + 4 data bits)
    // and data_out[0] is an extra redundant bit fixed to 0.
    //
    // Parity bits are calculated using XOR for even parity:
    //   data_out[1] = XOR(data_in[0], data_in[1], data_in[3])
    //   data_out[2] = XOR(data_in[0], data_in[2], data_in[3])
    //   data_out[4] = XOR(data_in[1], data_in[2], data_in[3])
    //
    // Data bits are placed as follows:
    //   data_out[3] = data_in[0]
    //   data_out[5] = data_in[1]
    //   data_out[6] = data_in[2]
    //   data_out[7] = data_in[3]
    //
    // data_out[0] is fixed to 0 as the redundant bit.

    // Assign data bits
    assign data_out[7] = data_in[3];           // MSB: data_in[3]
    assign data_out[6] = data_in[2];           // Next data bit
    assign data_out[5] = data_in[1];           // Next data bit
    assign data_out[3] = data_in[0];           // LSB of data bits

    // Calculate parity bits (even parity)
    assign data_out[1] = data_in[0] ^ data_in[1] ^ data_in[3]; // P1
    assign data_out[2] = data_in[0] ^ data_in[2] ^ data_in[3]; // P2
    assign data_out[4] = data_in[1] ^ data_in[2] ^ data_in[3]; // P3

    // Fixed redundant bit
    assign data_out[0] = 1'b0;
endmodule