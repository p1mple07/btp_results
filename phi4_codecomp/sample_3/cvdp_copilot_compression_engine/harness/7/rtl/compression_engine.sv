module compression_engine (
  input   logic        clk,
  input   logic        reset,

  input   logic [23:0] num_i,

  output  logic [11:0] mantissa_o,
  output  logic [3:0]  exponent_o
);

  // --------------------------------------------------------
  // Internal wire and regs
  // --------------------------------------------------------
  logic [23:12] exp_oh;
  logic [3:0]   exp_bin;
  logic [3:0]   exponent;

  logic [11:0]  mantissa;

  // Generate one-hot encoded exponent
  assign exp_oh[23] = num_i[23];
  for (genvar i = 22; i >= 12; i = i - 1) begin
    assign exp_oh[i] = num_i[i] & ~|exp_oh[23:i+1];
  end

  // Convert one-hot encoding to binary
  onehot_to_bin #(.ONE_HOT_W(12), .BIN_W(4)) exp_oh_bin (
    .oh_vec_i   (exp_oh),
    .bin_vec_o  (exp_bin)
  );

  // Compute exponent
  assign exponent = (|exp_oh) ? exp_bin + 4'h1 : exp_bin;

  // Compute mantissa
  assign mantissa = (|exp_oh) ? num_i[exponent+11-1-:12] : num_i[11:0];

  // Register outputs with clock
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

  // Combinational block for priority encoding
  always_comb begin
    bin_vec_o = {BIN_W{1'b0}}; // Default to 0
    for (i = 0; i < ONE_HOT_W; i = i + 1) begin
      if (oh_vec_i[i]) begin
        bin_vec_o = i[BIN_W-1:0];
        // Break out of the loop to prioritize the first set bit
      end
    end
  end

endmodule