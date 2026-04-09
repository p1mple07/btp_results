module pipeline_mac #(
    parameter DWIDTH = 16,  // Bit width for multiplicand and multiplier
    parameter N      = 4    // Number of data points to accumulate over
) (
    input logic clk,
    input logic rstn,
    input logic [DWIDTH-1:0] multiplicand,
    input logic [DWIDTH-1:0] multiplier,
    input logic valid_i,
    output logic [DWIDTH*N-1:0] result,
    output logic valid_out
);
  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  // Calculate the bit width of the accumulator to handle overflow
  localparam DWIDTH_ACCUMULATOR = DWIDTH * N;

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
  // Clock signal
  input logic clk;
  // Active low reset signal
  input logic rstn;
  // Input multiplicand
  input logic [DWIDTH-1:0] multiplicand;
  // Input multiplier
  input logic [DWIDTH-1:0] multiplier;
  // Input valid signal
  input logic valid_i;
  // Accumulated result output
  output logic [DWIDTH_ACCUMULATOR-1:0] result;
  // Output valid signal, indicates when result is ready
  output logic valid_out;

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;  // Register to store intermediate multiplication result
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;  // Register to store accumulated result
  logic [$clog2(N)-1:0] counter;                      // Counter to track the number of accumulations
  logic [$clog2(N)-1:0] counter_reg;                  // Register to hold the value of the counter
  logic count_rst, accumulator_rst;                   // Reset signals for counter and accumulator
  logic valid_out_s0, valid_out_s1, valid_out_s2;     // Intermediate Signals indicating that the valid output is ready
  logic valid_i_s1;                                   // Intermediate Signals indicating input valid signal

  // ----------------------------------------
  // - Procedural blocks
  // ----------------------------------------

  // Stage 1 of the pipeline: Perform multiplication
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      mult_result_reg <= 0;
    end else if (valid_i) begin
      mult_result_reg <= (multiplicand * multiplier);
    end
  end

  // Stage 2 of the pipeline: Accumulation logic
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      accumulation_reg <= 0;
    end else if (valid_i) begin
      accumulation_reg <= accumulation_reg + mult_result_reg;
    end
  end

  // N-bit counter to track the number of accumulations
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      counter_reg <= 0;
    end else begin
      counter_reg <= counter_reg + 1;
    end
  end

  // Register valid output for 2-stage pipeline
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      valid_out_s0 <= 0;
      valid_out_s1 <= 0;
      valid_out_s2 <= 0;
    end else begin
      valid_out_s0 <= (counter_reg == N-1);
      valid_out_s1 <= (counter_reg == N-1);
      valid_out_s2 <= (counter_reg == N-1);
    end
  end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
  assign counter = count_rst ? 'b1 : (valid_i & rstn ? (counter_reg + 'd1) : counter_reg);  // Increment counter on valid input
  assign valid_out_s0 = (counter_reg == N-1);    // Assert valid_out_s0 when N accumulations are done
  assign count_rst = valid_out_s1;                  // Reset counter after N accumulations
  assign accumulator_rst = valid_out_s1;            // Reset accumulator after N accumulations
  assign result = accumulation_reg;              // Output final result assignment
  assign valid_out = valid_out_s1 & ~valid_out_s2; // Valid_out signal generation by detecting posedge of previous stages of valid out

endmodule : pipeline_mac
