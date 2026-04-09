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
  assign exp_oh[23] = num_i[23];
  
  // Insert code for one-hot encoding of `exp_oh`

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
  // Insert code for extracting mantissa based on `exponent`

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

module onehot_to_bin #(
  parameter ONE_HOT_W = 32,  // Width of the one-hot input
  parameter BIN_W     = 5    // Width of the binary output
)(
  input   wire [ONE_HOT_W-1:0]  oh_vec_i,  // One-hot encoded input
  output  logic [BIN_W-1:0]     bin_vec_o  // Binary encoded output
);

  integer i;

 // Insert code for one-hot encoding of `exp_oh` for priority encoding

endmodule
