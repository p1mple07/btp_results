module reverse_bits (
    input  [31:0] num_in,
    output [31:0] num_out
);

  // Reverse the bits of num_in so that the LSB becomes the MSB of num_out.
  assign num_out = {num_in[0], num_in[1], num_in[2], num_in[3],
                    num_in[4], num_in[5], num_in[6], num_in[7],
                    num_in[8], num_in[9], num_in[10], num_in[11],
                    num_in[12], num_in[13], num_in[14], num_in[15],
                    num_in[16], num_in[17], num_in[18], num_in[19],
                    num_in[20], num_in[21], num_in[22], num_in[23],
                    num_in[24], num_in[25], num_in[26], num_in[27],
                    num_in[28], num_in[29], num_in[30], num_in[31]};

endmodule