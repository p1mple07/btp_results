module hamming_code_receiver;
  reg [7:0] data_in;
  reg [3:0] data_out;

  always @(*) begin
    // Compute parity checks
    wire c1 = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
    wire c2 = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    wire c3 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

    // Determine error location
    if (c1 == 1) data_out[0] = ~data_in[0];
    else if (c2 == 1) data_out[1] = ~data_in[1];
    else if (c3 == 1) data_out[2] = ~data_in[2];
    else data_out = data_in;
  end
endmodule
