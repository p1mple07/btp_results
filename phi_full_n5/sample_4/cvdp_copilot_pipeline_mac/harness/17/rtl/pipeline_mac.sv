module pipeline_mac #(
    parameter DWIDTH = 16,  // Bit width for multiplicand and multiplier
    parameter N      = 4    // Number of data points to accumulate over
) (
    clk,
    rstn,
    multiplicand,
    multiplier,
    valid_i,
    result,
    valid_out
);
  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  localparam DWIDTH_ACCUMULATOR = DWIDTH * N;  // Bit width for the accumulator to avoid overflow

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
  input logic clk;                                // Clock signal
  input logic rstn;                               // Active low reset signal
  input logic [DWIDTH-1:0] multiplicand;          // Input multiplicand
  input logic [DWIDTH-1:0] multiplier;            // Input multiplier
  input logic valid_i;                            // Input valid signal
  output logic [DWIDTH_ACCUMULATOR-1:0] result;   // Accumulated result output
  output logic valid_out;                         // Output valid signal, indicates when result is ready

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;    // Register to store intermediate multiplication result
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;   // Register to store accumulated result
  logic [$clog2(N):0] counter;                      // Counter to track the number of accumulations
  logic [$clog2(N):0] counter_reg;                  // Register to hold the value of the counter
  logic count_rst, accumulator_rst;                 // Reset signals for counter and accumulator
  logic valid_out_s0,valid_out_s1,valid_out_s2;      // Intermediate Signals indicating that the valid output is ready
  logic valid_i_s1;                                 // Intermediate Signals indicating input valid signal

  // ----------------------------------------
  // - Procedural blocks
  // ----------------------------------------

  // Stage 1 of the pipeline: Perform multiplication
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      mult_result_reg <= 'b0;
    end else if (valid_i) begin
      mult_result_reg <= multiplicand * multiplier;
    end
  end

  // Stage 2 of the pipeline: Accumulation logic
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      accumulation_reg <= 'b0;
    end else if (valid_i) begin
      accumulation_reg <= accumulation_reg + mult_result_reg;
    end
  end

  // N-bit counter to track the number of accumulations
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      counter_reg <= 'b0;
    end else begin
      counter_reg <= counter_reg + 1;
      if (counter_reg == N-1) begin
        count_rst <= 1;
        accumulator_rst <= 1;
      end
    end
  end

  // Register valid output for 2-stage pipeline
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      valid_out_s1 <= 0;
      valid_out_s2 <= 0;
    </verilog>
