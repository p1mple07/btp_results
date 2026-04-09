module binary_to_one_hot_decoder_sequencial #(
  parameter int BINARY_WIDTH = 5,
  parameter int OUTPUT_WIDTH = 32
) (
  input  logic [BINARY_WIDTH-1:0] i_binary_in,
  input  logic                       i_clk,
  input  logic                       i_rstb,
  output logic [OUTPUT_WIDTH-1:0] o_one_hot_out
);
  
  // Reset behavior
  always_ff @(posedge i_clk or negedge i_rstb) begin
    if (!i_rstb)
      o_one_hot_out <= '0;
    else
      o_one_hot_out <= {{(OUTPUT_WIDTH-BINARY_WIDTH){1'b0}}, i_binary_in};
  end
  
endmodule