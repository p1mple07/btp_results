module custom_byte_enable_ram #(
  parameter int XLEN
) (
  input bit clk,

  // Port A
  input bit [XLEN-1:0] addr_a,
  input bit en_a,
  input bit [XLEN-1:0] be_a,
  input bit [XLEN-1:0] data_in_a,
  output bit [XLEN-1:0] data_out_a,

  // Port B
  input bit clk_b,
  input bit en_b,
  input bit [XLEN-1:0] be_b,
  input bit [XLEN-1:0] data_in_b,
  output bit [XLEN-1:0] data_out_b
);

endmodule