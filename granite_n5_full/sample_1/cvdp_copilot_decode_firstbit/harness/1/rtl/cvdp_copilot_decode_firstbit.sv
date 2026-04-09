module cvdp_copilot_decode_firstbit #(
  parameter int unsigned InWidth_g = 32,
  parameter bit InReg_g = 1'b1,
  parameter bit OutReg_g = 1'b1,
  parameter int unsigned PlREGS_g = 1
) (
  input wire clk_i,
  input wire rst_ni,
  input wire [InWidth_g-1:0] in_data_i,
  input wire in_valid_i,
  output logic [InWidth_g-1:0] out_firstbit_o,
  output logic out_found_o,
  output logic out_valid_o
);

  // Implementation of the first-bit decoder logic goes here...

endmodule