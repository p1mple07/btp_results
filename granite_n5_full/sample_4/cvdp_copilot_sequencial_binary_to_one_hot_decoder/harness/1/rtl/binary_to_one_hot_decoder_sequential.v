module binary_to_one_hot_decoder_sequencial #(
  parameter int BINARY_WIDTH = 5,
  parameter int OUTPUT_WIDTH = 32
)(
  input wire [BINARY_WIDTH-1:0] i_binary_in,
  input wire i_clk,
  input wire i_rstb,
  output logic [OUTPUT_WIDTH-1:0] o_one_hot_out
);

  logic [OUTPUT_WIDTH-1:0] reg_state;

  always_ff @(posedge i_clk or posedge i_rstb) begin
    if (i_rstb == 1'b0) begin
      // Asynchronous reset
      reg_state <= '0;
    end else begin
      // Sequential update
      reg_state <= {reg_state[OUTPUT_WIDTH-2:0], i_binary_in};
    end
  end

  assign o_one_hot_out = (reg_state == i_binary_in);

endmodule