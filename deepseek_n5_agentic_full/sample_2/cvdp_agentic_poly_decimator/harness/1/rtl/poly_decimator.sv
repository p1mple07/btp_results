module rtl/poly_decimator #(
  parameter M = 4,
  parameter TAPS = 8,
  parameter COEFF_WIDTH = 16,
  parameter DATA_WIDTH = 16
)
(
  input logic clamp(clk),
  input logic arst_n,
  input logic [DATA_WIDTH-1:0] in_sample,
  input logic valid_in,
  output logic [ACC_WIDTH-1:0] out_sample,
  output logic valid
);

  // State variables
  reg current_stage = 0;
  reg valid_stage = 0;

  // Module instances
  shift_register#(TAPS=32, DATA_WIDTH=16) shift_reg (
    .clk(clamp.clk),
    .arst_n(arst_n),
    .load(!valid_in),
    .new_sample(in_sample),
    .data_out_val(!valid_stage)
  );

  coeff_ram#(
    NUM_COEFFS = 32,
    DATA_WIDTH = 16
  ) coeff_ram (
    .clk(clamp.clk),
    .addr = 0,
    .data_out = 0
  );

  poly_filter#(
    M = 4,
    TAPS = 8,
    COEFF_WIDTH = 16,
    DATA_WIDTH = 16
  ) poly_filter (
    .clk(clamp.clk),
    .arst_n(arst_n),
    .in_sample = in_sample,
    .valid_in = valid_in,
    .out_sample = out_sample,
    .valid_out = valid
  );

  adder_tree#(
    NUM_INPUTS = 8,
    DATA_WIDTH = 32
  ) adder_tree (
    .clk(clamp.clk),
    .arst_n(arst_n),
    .valid_in = valid_stage,
    .data_in = poly_filter.sum_out,
    .sum_out = out_sample,
    .valid_out = valid
  );

  // State machine logic
  initial_state: current_stage = 0;
  always_ff @posedge(clk) begin
    case(current_stage)
    default: current_stage = 0;
    wait #clog2(M * TAPS); // Wait time for full window collection
    endcase

    // Initialization phase
    valid_stage = 0;
    state_reg[0] <= in_sample;
    valid_state0 <= 1'b1;
    valid_stage0 <= 1'b1;
    state_reg[1] <= poly_filter.filter_out;
    valid_stage1 <= 1'b0;

    // Processing phase
    valid_stage = 1;
    state_reg[1] <= poly_filter.filter_out;
    valid_stage0 <= 1'b0;
    valid_stage1 <= 1'b1;
    state_reg[2] <= adder_tree.sum_out;
    valid_stage2 <= 1'b1;

    // Output phase
    valid_stage = 2;
    state_reg[2] <= adder_tree.sum_out;
    valid_stage0 <= 1'b0;
    valid_stage1 <= 1'b0;
    valid_stage2 <= 1'b0;

    // Update output
    out_sample <= adder_tree.sum_out;
    valid <= 1'b0;

    // Cycle back to initialization
    current_stage = 0;
  endcase
  end