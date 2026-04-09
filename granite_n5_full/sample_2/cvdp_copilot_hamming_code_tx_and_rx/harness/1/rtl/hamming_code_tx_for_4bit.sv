module hamming_code_tx_for_4bit (
  input [3:0] data_in,
  output reg [7:0] data_out
);

always @(*) begin
  data_out = 8'b0; // Redundant bit set to 0
  data_out[1] = ^(data_in[0] & data_in[1] & data_in[3]); // Parity bit calculation
  data_out[2] = ^(data_in[0] & data_in[2] & data_in[3]); // Parity bit calculation
  data_out[4] = ^(data_in[1] & data_in[2] & data_in[3]); // Parity bit calculation
  data_out[3] = data_in[0]; // Preserve the order of input data
  data_out[5] = data_in[1];
  data_out[6] = data_in[2];
  data_out[7] = data_in[3];
end

endmodule