Module implementation for pipeline_mac
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
  // Parameters
  parameter DWIDTH_ACCUMULATOR = $clog2(N+1)*DWIDTH;

  // Inputs and outputs
  input  logic        clk;                                // Clock signal
  input  logic        rstn;                               // Active low reset signal
  input  logic [DWIDTH-1:0] multiplicand;          // Input multiplicand
  input  logic [DWIDTH-1:0] multiplier;            // Input multiplier
  input  logic        valid_i;                            // Input valid signal
  output logic [DWIDTH_ACCUMULATOR-1:0] result;   // Accumulated result output
  output logic        valid_out;                         // Output valid signal, indicates when result is ready

  // Internal signals
  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;    // Register to store intermediate multiplication result
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;   // Register to store accumulated result
  logic [$clog2(N)-1:0]       counter;                       // Counter to track the number of accumulations
  logic [$clog2(N)-1:0]       counter_reg;                   // Register to hold the value of the counter
  logic                         count_rst, accumulator_rst;     // Reset signals for counter and accumulator
  logic                         valid_out_s0,valid_out_s1,valid_out_s2;  // Intermediate Signals indicating that the valid output is ready
  logic                         valid_i_s1;                     // Intermediate Signals indicating input valid signal

  // Pipeline stages
  // Stage 1: Perform multiplication
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      mult_result_reg <= 'h0;
    end else if (valid_i_s1) begin
      mult_result_reg <= {DWIDTH{multiplicand[DWIDTH-1]}} * multiplier;
    end
  end

  // Stage 2: Accumulation logic
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      accumulation_reg <= 'h0;
    end else if (valid_out_s1) begin
      accumulation_reg <= mult_result_reg + accumulation_reg[$clog2(N)-1:0];
    end
  end

  // N-bit counter to track the number of accumulations
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      counter <= 'b1;
      counter_reg <= 'b1;
    end else if (valid_i_s1) begin
      counter <= (counter_reg + 'd1);
    end
  end

  // Register valid output for 2-stage pipeline
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      valid_out_s0 <= 1'b0;
    end else begin
      valid_out_s0 <= (counter_reg == N-1);
    end
  end

  // Reset counters after N accumulations
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      count_rst <= 1'b0;
      accumulator_rst <= 1'b0;
    end else begin
      count_rst <= valid_out_s1;
      accumulator_rst <= valid_out_s1;
    end
  end

  // Final result assignment
  assign result = accumulation_reg;

  // Output valid signal generation by detecting posedge of previous stages of valid out
  assign valid_out = valid_out_s1 & ~valid_out_s2;

endmodule