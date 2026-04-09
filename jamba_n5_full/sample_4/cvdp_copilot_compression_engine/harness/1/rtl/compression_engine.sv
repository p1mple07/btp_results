module compression_engine (
  input   logic        clk,
  input   logic        reset,
  input   logic [23:0] num_i,
  output  logic [11:0] mantissa_o,
  output  logic [3:0]  exponent_o
);

  logic [23:0] exp_oh;
  logic [3:0]  exp_bin;
  logic [3:0]  exponent;
  logic [11:0] mantissa;

  assign exp_oh[23] = num_i[23];

  assign exp_bin = onehot_to_bin(exp_oh, 12);

  assign exponent = (exp_oh[23]) ? exp_bin + 4'h1 : exp_bin;

  if (num_i == 24'h0) begin
    mantissa_o = 12'd0;
    exponent_o = 4'h0;
  end else begin
    mantissa_o = num_i[11:0];
    exponent_o = exponent;
  end

endmodule

module onehot_to_bin #(
  parameter ONE_HOT_W = 32,
  parameter BIN_W     = 5
) (
  input   wire [ONE_HOT_W-1:0]  oh_vec_i,
  output  logic [BIN_W-1:0]     bin_vec_o
);

  integer i;

  assign bin_vec_o = oh_vec_i;

endmodule
