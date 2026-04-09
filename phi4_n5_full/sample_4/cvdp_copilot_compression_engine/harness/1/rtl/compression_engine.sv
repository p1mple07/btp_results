module compression_engine (
  input   logic        clk,
  input   logic        reset,
  input   logic [23:0] num_i,
  output  logic [11:0] mantissa_o,
  output  logic [3:0]  exponent_o
);

  // --------------------------------------------------------
  // Internal wires and registers
  // --------------------------------------------------------
  logic [23:12] exp_oh;         // One-hot encoded exponent (for bits 23 downto 12)
  logic [3:0]   exp_bin;        // Binary exponent (index within the one-hot vector)
  logic [3:0]   exponent;       // Adjusted exponent output
  logic [11:0]  mantissa;       // Mantissa output

  // --------------------------------------------------------
  // One-Hot Encoding of the Exponent
  // --------------------------------------------------------
  // For each bit i (from 22 downto 12), generate:
  //   exp_oh[i] = num_i[i] & ~(|num_i[23:i+1])
  genvar i;
  generate
    for (i = 22; i >= 12; i = i - 1) begin : onehot_gen
      assign exp_oh[i] = num_i[i] & ~(|num_i[23:i+1]);
    end
  endgenerate

  // Highest bit is assigned separately
  assign exp_oh[23] = num_i[23];

  // --------------------------------------------------------
  // One-Hot to Binary Conversion
  // --------------------------------------------------------
  // The onehot_to_bin module converts the one-hot vector into the zero-based index.
  onehot_to_bin #(
    .ONE_HOT_W(12),
    .BIN_W(4)
  ) exp_oh_bin (
    .oh_vec_i(exp_oh),
    .bin_vec_o(exp_bin)
  );

  // Adjust the exponent: if any one-hot bit is detected, add 1; otherwise, exponent remains 0.
  assign exponent = (|exp_oh) ? exp_bin + 4'h1 : exp_bin;

  // --------------------------------------------------------
  // Mantissa Extraction Logic
  // --------------------------------------------------------
  // If the input vector is zero, output mantissa = 0.
  // If exponent is 0, the most significant set bit is in the lower 12 bits so:
  //   mantissa = num_i[11:0]
  // Otherwise, extract the most significant 12 bits starting from the bit (exponent - 1).
  assign mantissa = (num_i == 24'd0) ? 12'd0 :
                    (exponent == 4'd0) ? num_i[11:0] :
                    num_i[(exponent - 1) +: 12];

  // --------------------------------------------------------
  // Output Registering
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

// ------------------------------------------------------------
// onehot_to_bin Module
// ------------------------------------------------------------
module onehot_to_bin #(
  parameter ONE_HOT_W = 32,  // Width of the one-hot input
  parameter BIN_W     = 5    // Width of the binary output
)(
  input   wire [ONE_HOT_W-1:0]  oh_vec_i,  // One-hot encoded input
  output  logic [BIN_W-1:0]     bin_vec_o  // Binary encoded output
);

  integer i;
  // Convert the one-hot vector to a binary index.
  // Iterate over the one-hot vector and output the index of the set bit.
  always_comb begin
    bin_vec_o = 0;
    for (i = 0; i < ONE_HOT_W; i = i + 1) begin
      if (oh_vec_i[i])
        bin_vec_o = i;
    end
  end

endmodule