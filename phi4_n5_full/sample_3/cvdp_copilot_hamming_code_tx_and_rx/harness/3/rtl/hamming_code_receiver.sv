module hamming_code_receiver (
    input  wire [7:0] data_in,
    output wire [3:0] data_out
);

  // Calculate syndrome bits for even parity error detection
  // c3: XOR of bits at positions with LSB = 1: data_in[1], data_in[3], data_in[5], data_in[7]
  wire c3 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];

  // c2: XOR of bits at positions with second LSB = 1: data_in[2], data_in[3], data_in[6], data_in[7]
  wire c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];

  // c1: XOR of bits at positions with MSB = 1: data_in[4], data_in[5], data_in[6], data_in[7]
  wire c1 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

  // Combine syndrome bits: {c1, c2, c3}
  wire [2:0] syndrome = {c1, c2, c3};

  // Correct the error if detected.
  // If syndrome is nonzero, the bit at that position (1-indexed) in data_in is flipped.
  // Note: syndrome == 3'b000 indicates an error in the redundant bit (data_in[0]),
  //       so no correction is applied to the 7-bit Hamming code.
  wire [7:0] corrected_data;
  assign corrected_data = data_in ^ ((syndrome != 3'b000) ? (8'h01 << syndrome) : 8'h00);

  // Extract the 4 data bits from the corrected data.
  // According to the specification, data bits are located at:
  //   data_in[3] -> data bit 1
  //   data_in[5] -> data bit 2
  //   data_in[6] -> data bit 3
  //   data_in[7] -> data bit 4
  assign data_out = {corrected_data[7], corrected_data[6], corrected_data[5], corrected_data[3]};

endmodule