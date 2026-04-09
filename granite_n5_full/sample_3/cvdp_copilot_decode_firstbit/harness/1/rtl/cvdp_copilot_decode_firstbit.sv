module cvdp_copilot_decode_firstbit #(
  parameter int unsigned InWidth_g = 32,
  parameter bit          InReg_g   = 1'b1,
  parameter bit          OutReg_g  = 1'b1,
  parameter int unsigned PlREGS_g = 1
)(
  input  logic                     Clk_i,
  input  logic                     Rst_ni,

  input  logic [InWidth_g-1:0]   In_Data_i,
  input  logic                     In_Valid_i,
  output logic [InWidth_g-1:0]   Out_FirstBit_o,
  output logic                     Out_Found_o,
  output logic                     Out_Valid_o
);

  // Your code goes here

endmodule