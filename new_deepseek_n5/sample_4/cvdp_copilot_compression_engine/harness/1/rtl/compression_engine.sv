module compression_engine (
  input   logic        clk,
  input   logic        reset,
  input   logic [23:0] num_i,
  output  logic [11:0] mantissa_o,
  output  logic [3:0]  exponent_o
);

  // --------------------------------------------------------
  // One-Hot Encoding of the Exponent
  // --------------------------------------------------------
  logic [23:0] exp_oh;
  assign exp_oh[23] = num_i[23];
  generate
    for (integer i = 22; i >= 0; i = i - 1)
      exp_oh[i] = num_i[i] & ~num_i[i+1:23];
  endgenerate

  // Use the `onehot_to_bin` module to convert one-hot to binary exponent
  onehot_to_bin #(
    .ONE_HOT_W(24),
    .BIN_W(4)
  ) exp_oh_bin (
    .oh_vec_i(exp_oh),
    .bin_vec_o(exp_bin)
  );
  
  assign exponent = (|exp_oh) ? exp_bin : 0;

  // --------------------------------------------------------
  // Mantissa Extraction Logic
  // --------------------------------------------------------
  logic [11:0] mantissa;

  if (num_i == 0)
    mantissa = 0;
  else
    mantissa = num_i[exponent + 11 : exponent];

  // --------------------------------------------------------
  // Output assignments
  // --------------------------------------------------------
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