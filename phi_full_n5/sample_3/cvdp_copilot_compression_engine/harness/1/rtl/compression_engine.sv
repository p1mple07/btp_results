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
  logic [23:12] exp_oh;         // One-hot encoded exponent
  logic [3:0]   exp_bin;        // Binary exponent
  logic [3:0]   exponent;       // Adjusted exponent
  logic [11:0]  mantissa;       // Mantissa
  
  // --------------------------------------------------------
  // One-Hot Encoding of the Exponent
  // --------------------------------------------------------
  always @(num_i) begin
    exp_oh = 12'h000000000000;
    for (int i = 23; i >= 0; i = i - 1) begin
      exp_oh[i] = num_i[i] & ~|num_i[23:i+1];
    end
  end
  
  // Use the `onehot_to_bin` module to convert one-hot to binary exponent
  onehot_to_bin #(
    .ONE_HOT_W(12),
    .BIN_W(4)
  ) exp_oh_bin (
    .oh_vec_i(exp_oh),
    .bin_vec_o(exp_bin)
  );
  
  assign exponent = (|exp_oh) ? exp_bin + 4'h1 : exp_bin;

  // --------------------------------------------------------
  // Mantissa Extraction Logic
  // --------------------------------------------------------
  // Extract the 12-bit mantissa based on `exponent`
  always @(num_i) begin
    if (num_i == 24'h000000) begin
      mantissa_o <= 12'h0;
    end else begin
      if (exponent == 4'd0) begin
        mantissa_o <= num_i[11:0];
      end else begin
        mantissa_o <= num_i[exponent - 4'd1 : exponent - 4'd1 + 11];
      end
    end
  end

  // --------------------------------------------------------
  // Output assignments
  // --------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      exponent_o <= 4'd0;
      mantissa_o <= 12'h0;
    end else begin
      exponent_o <= exponent;
      mantissa_o <= mantissa;
    end
  end

endmodule

module onehot_to_bin #(
  parameter ONE_HOT_W = 12,  // Width of the one-hot input
  parameter BIN_W     = 4    // Width of the binary output
)(
  input   wire [ONE_HOT_W-1:0]  oh_vec_i,  // One-hot encoded input
  output  logic [BIN_W-1:0]     bin_vec_o  // Binary encoded output
);

  integer i;

  // Convert one-hot to binary
  always @(oh_vec_i) begin
    bin_vec_o = {(ONE_HOT_W-1){1'b0}};
    for (i = ONE_HOT_W-2; i >= 0; i = i - 1) begin
      if (oh_vec_i[i]) begin
        bin_vec_o[i] = 1;
      end else begin
        bin_vec_o[i] = 0;
      end
    end
  end

endmodule
