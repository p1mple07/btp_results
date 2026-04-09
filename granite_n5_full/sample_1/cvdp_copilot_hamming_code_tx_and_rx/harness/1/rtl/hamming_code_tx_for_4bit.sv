module hamming_code_tx_for_4bit (
  input logic [3:0] data_in,
  output logic [7:0] data_out
);

  // Even Parity Calculation
  assign data_out[1] = ^(data_in & {{2{1'b0}}, 1'b1});
  assign data_out[2] = ^(data_in & {{3{1'b0}}, 2'b11});
  assign data_out[4] = ^(data_in & {3'b0, 1'b1, 1'b1});
  assign data_out[3:0] = data_in;

  // Redundant Bit
  assign data_out[0] = 1'b0;
  
endmodule