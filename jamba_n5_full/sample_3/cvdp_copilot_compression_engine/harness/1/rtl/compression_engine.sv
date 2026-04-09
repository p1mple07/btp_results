module compression_engine (
  input   logic        clk,
  input   logic        reset,
  input   logic [23:0] num_i,
  output  logic [11:0] mantissa_o,
  output  logic [3:0]  exponent_o
);

  logic [23:12] exp_oh;
  logic [3:0] exp_bin;
  logic [3:0] exponent;
  logic [11:0] mantissa;

  // One‑hot encoding of the most significant set bit
  assign exp_oh[23] = num_i[23];
  for (integer i = 0; i < 24; i++) begin
    exp_oh[i] = num_i[i] & ~(num_i[23:i+1]);
  end

  // Convert one‑hot to binary exponent
  onehot_to_bin #(
    .ONE_HOT_W(12),
    .BIN_W(4)
  ) exp_oh_bin (
    .oh_vec_i(exp_oh),
    .bin_vec_o(exp_bin)
  );

  assign exponent = (exp_oh[0]) ? exp_bin + 4'h1 : exp_bin;

  // Extract mantissa based on the exponent
  if (exponent == 0) begin
    mantissa = num_i[11:0];
  else begin
    mantissa = (num_i >> (exp_oh[0] ? 1 : 0)) [12:0];
  end
end

always @(posedge clk or posedge reset) begin
  if (reset) begin
    exponent_o <= 4'd0;
    mantissa_o <= 12'd0;
  end else begin
    exponent_o <= exponent;
    mantissa_o <= mantissa;
  end
end

endmodule
