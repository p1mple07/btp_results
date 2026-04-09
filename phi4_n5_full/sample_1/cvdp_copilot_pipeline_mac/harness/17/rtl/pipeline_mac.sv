// File: rtl/pipeline_mac.sv

module pipeline_mac #(
  parameter DWIDTH = 16,  // Bit width for multiplicand and multiplier
  parameter N      = 4    // Number of data points to accumulate over
) (
  input  logic         clk,         // Clock signal
  input  logic         rstn,        // Active low reset signal
  input  logic [DWIDTH-1:0] multiplicand,  // Input multiplicand
  input  logic [DWIDTH-1:0] multiplier,    // Input multiplier
  input  logic         valid_i,     // Input valid signal
  output logic [DWIDTH_ACCUMULATOR-1:0] result,  // Accumulated result output
  output logic         valid_out    // Output valid signal, indicates when result is ready
);

  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  // The maximum product for two DWIDTH-bit numbers is nearly 2^(2*DWIDTH).
  // After N accumulations, the maximum value is N*(2^(2*DWIDTH)-something).
  // A safe exact bit width is: 2*DWIDTH + $clog2(N)
  localparam DWIDTH_ACCUMULATOR = 2*DWIDTH + $clog2(N);

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
  // (Inputs/outputs already declared above)

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;   // Register to store intermediate multiplication result
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;    // Register to store accumulated result
  logic [$clog2(N):0] counter;                        // Combinational counter (reflects counter_reg)
  logic [$clog2(N):0] counter_reg;                    // Registered counter value
  logic count_rst, accumulator_rst;                  // Reset signals for counter and accumulator
  logic valid_out_s0, valid_out_s1, valid_out_s2;     // Pipeline stages for valid output

  // ----------------------------------------
  // - Procedural blocks
  // ----------------------------------------

  // Stage 1 of the pipeline: Perform multiplication
  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      mult_result_reg <= '0;
    else if (valid_i)
      mult_result_reg <= multiplicand * multiplier;
    // When valid_i is low, hold the previous multiplication result
  end

  // Stage 2 of the pipeline: Accumulation logic
  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      accumulation_reg <= '0;
    else if (accumulator_rst)
      accumulation_reg <= '0;
    else if (valid_i)
      accumulation_reg <= accumulation_reg + mult_result_reg;
    // When valid_i is low, hold the accumulated value
  end

  // N-bit counter to track the number of accumulations
  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      counter_reg <= '0;
    else if (valid_i && rstn) begin