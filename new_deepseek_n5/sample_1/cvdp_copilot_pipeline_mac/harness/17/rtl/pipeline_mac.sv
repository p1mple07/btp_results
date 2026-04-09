module pipeline_mac #(
    parameter DWIDTH = 16,
    parameter N      = 4
) (
    clk,
    rstn,
    multiplicand,
    multiplier,
    valid_i,
    result,
    valid_out
);
  // Calculate accumulator width
  parameter DWIDTH_ACCUMULATOR = 34;

  // Interface Definitions
  input logic clk;
  input logic rstn;
  input logic [DWIDTH-1:0] multiplicand;
  input logic [DWIDTH-1:0] multiplier;
  input logic valid_i;
  output logic [DWIDTH_ACCUMULATOR-1:0] result;
  output logic valid_out;

  // Internal signals
  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;
  logic [2:0] counter;
  logic [2:0] counter_reg;
  logic count_rst, accumulator_rst;
  logic valid_out_s0, valid_out_s1, valid_out_s2;
  logic valid_i_s1;

  // Stage 1: Multiplication
  always @(posedge clk or negedge rstn) begin
    if (valid_i_s1 && !rstn) begin
      mult_result_reg = multiplicand * multiplier;
    end
  end

  // Stage 2: Accumulation
  always @(posedge clk or negedge rstn) begin
    if (valid_i_s1 && !rstn && counter_reg == N-1) begin
      accumulation_reg = accumulation_reg + mult_result_reg;
      valid_out_s1 = 1;
      valid_out_s2 = 0;
    end
  end

  // Counter
  always @(posedge clk or negedge rstn) begin
    if (valid_i_s1 && !rstn && counter_reg < N) begin
      counter_reg = counter_reg + 1;
    end
  end

  // Register valid output
  always @(posedge clk or negedge rstn) begin
    if (rstn) begin
      result = 0;
      valid_out = 0;
    else if (valid_out_s1 && !rstn) begin
      result = accumulation_reg;
      valid_out = 1;
      valid_out_s1 = 0;
      valid_out_s2 = 1;
    else if (valid_out_s2 && !rstn) begin
      result = accumulation_reg;
      valid_out = 0;
      valid_out_s1 = 1;
      valid_out_s2 = 0;
    end
  end
endmodule