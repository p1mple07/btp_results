module compression_engine (
  input   logic        clk,
  input   logic        reset,
  input   logic [23:0] num_i,
  output  logic [11:0] mantissa_o,
  output  logic [3:0]  exponent_o
);

  // 1. One-Hot Encoding of the Exponent
  logic [23:12] exp_oh;
  logic [3:0]   exp_bin;
  logic [3:0]   exponent;
  logic [11:0]  mantissa;

  assign exp_oh[23] = num_i[23];

  // onehot_to_bin module instantiation
  onehot_to_bin #(
    .ONE_HOT_W(12),
    .BIN_W(4)
  ) uut (
    .oh_vec_i(exp_oh),
    .bin_vec_o(exp_bin)
  );

  assign exponent = (~exp_oh[0]) ? exp_bin + 4'h1 : exp_bin;

  // 2. Mantissa Extraction Logic
  if (exponent == 0) begin
    mantissa = {12{num_i[11:0]}};
  else begin
    mantissa = {12{num_i[11:9]}};
  end

  // Output assignments
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
