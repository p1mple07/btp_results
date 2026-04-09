module hamming_code_tx_for_4bit(input [3:0] data_in, output reg [7:0] data_out);
  assign data_out[0] = 0; // Fixed redundant bit
  assign data_out[1] = ^(data_in & {1'b0, data_in[2], data_in[3]}); // Parity bit for positions 0, 1, and 3
  assign data_out[2] = ^(data_in & {1'b0, data_in[0], data_in[3]}); // Parity bit for positions 0, 2, and 3
  assign data_out[4] = ^(data_in & {1'b0, data_in[1], data_in[3]}); // Parity bit for positions 1, 2, and 3
  assign data_out[3:5] = data_in[0:2]; // Preserve order of input data

  // Additional checks or error handling can be added here as needed
endmodule