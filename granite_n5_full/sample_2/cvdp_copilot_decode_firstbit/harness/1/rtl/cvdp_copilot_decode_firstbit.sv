module cvdp_copilot_decode_firstbit #(
  parameter int InWidth_g = 32,
  parameter bit InReg_g = 1,
  parameter bit OutReg_g = 1,
  parameter int PlRegs_g = 1
)(
  input  logic                     Clk_i,
  input  logic                     Rst_ni,
  input  logic [InWidth_g-1:0]  In_Data_i,
  input  logic                     In_Valid_i,
  output logic [InWidth_g-1:0]  Out_FirstBit_o,
  output logic                     Out_Found_o,
  output logic                     Out_Valid_o
);

  // Module implementation here...

endmodule