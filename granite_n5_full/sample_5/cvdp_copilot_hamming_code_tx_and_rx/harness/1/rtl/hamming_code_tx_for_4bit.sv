module hamming_code_tx_for_4bit(
  input logic [3:0] data_in,
  output logic [7:0] data_out
);

  // Encoding Logic
  assign data_out[0] = 1'b0; // Redundant Bit
  assign data_out[1] = ^(data_in & {1'b0, data_in[2], data_in[3]}); // Parity Bit 1
  assign data_out[2] = ^(data_in & {data_in[0], 1'b0, data_in[3]}); // Parity Bit 2
  assign data_out[4] = ^(data_in & {1'b0, data_in[1], data_in[3]}); // Parity Bit 3
  assign data_out[3:5] = data_in[0:2]; // Preserve Order of Data Bits

  // Assigning Parity Bits for Checking Errors
  assign data_out[6] = ^(data_in & {data_in[1], data_in[2], 1'b0}); // Parity Bit 4
  assign data_out[7] = ^(data_in & {data_in[0], data_in[1], 1'b0}); // Parity Bit 5

endmodule