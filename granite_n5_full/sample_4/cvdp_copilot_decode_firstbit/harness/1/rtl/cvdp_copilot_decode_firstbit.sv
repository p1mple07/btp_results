module cvdp_copilot_decode_firstbit
#(
  parameter integer InWidth_g = 32,
  parameter bit InReg_g = 1,
  parameter bit OutReg_g = 1,
  parameter integer PlRegs_g = 1
)
(
  input  logic          Clk,
  input  logic          Rst,
  
  input  logic [InWidth_g-1:0] In_Data,
  input  logic                 In_Valid,

  output logic [$clog2(InWidth_g)-1:0] Out_FirstBit,
  output logic                         Out_Found,
  output logic                         Out_Valid
);

  // Your code implementation goes here

endmodule