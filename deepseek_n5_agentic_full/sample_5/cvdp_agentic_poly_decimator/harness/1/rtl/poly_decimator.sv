module poly_decimator #(
  parameter M = 4,
  parameter TAPS = 8,
  parameter COEFF_WIDTH = 16,
  parameter DATA_WIDTH = 16
)
(
  input  logic                         clk,
  input  logic                         arst_n,
  input  logic [DATA_WIDTH-1:0]        data_in [0:M*TAPS-1],
  output logic [COEFF_WIDTH+DATA_WIDTH+ $clog2(TAPS)+$clog2(M)-1:0] filter_out,
  output logic                         valid_out
);

  // Shift register for capturing samples
  shift_register #(
    .DATA_WIDTH  (DATA_WIDTH),
    .TAPS        (M * TAPS)
  ) shift_reg (
    .clk          (clk),
    .arst_n       (arst_n),
    .load         (.valid_in),
    .new_sample  (.data_in),
    .data_out     (.data_out),
    .data_out_val  (.valid_in)
  );

  // Polyphase filter structure
  localparam NUM Phases = M;
  localparam NUM Stages = $clog2(M);
  
  generate
    for (int phase = 0; phase < PHASES; phase++) begin
      poly_filter #(
        .M          (M),
        .TAPS       (TAPS),
        .COEFF_WIDTH (COEFF_WIDTH),
        .DATA_WIDTH  (DATA_WIDTH)
      ) poly_filter_phase (
        .clk              (clk),
        .arst_n          (arst_n),
        .phase           (phase),
        .input           (.data_out[phase:TAPS-1]),
        .valid_in         (.valid_out),
        .filter_out       (.filter_out),
        .valid_out        (.valid_out)
      );
    end
  endgenerate

  // Adder tree for combining branch results
  adder_tree #(
    .NUM_INPUTS  (TAPS),
    .DATA_WIDTH  (COEFF_WIDTH + DATA_WIDTH + $clog2(TAPS))
  ) adder_tree_combined (
    .clk          (clk),
    .arst_n       (arst_n),
    .valid_in      (.valid_out),
    .data_in       (filter_out),
    .sum_out        (.filter_out),
    .valid_out     (.valid_out)
  );
endmodule