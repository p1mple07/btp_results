module cipher (
  input wire clk,
  input wire rst_n,
  input wire start,
  input wire [31:0] data_in,
  input wire [15:0] key,
  output reg [31:0] data_out,
  output reg done
);

  //... (code implementation goes here)

endmodule