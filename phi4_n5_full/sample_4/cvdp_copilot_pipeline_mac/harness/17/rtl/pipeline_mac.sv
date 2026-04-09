
module pipeline_mac #(
    parameter DWIDTH = 16,  // Bit width for multiplicand and multiplier
    parameter N      = 4    // Number of data points to accumulate over
) (
    input logic clk,                                // Clock signal
    input logic rstn,                               // Active low reset signal
    input logic [DWIDTH-1:0] multiplicand,          // Input multiplicand
    input logic [DWIDTH-1:0] multiplier,            // Input multiplier
    input logic valid_i,                            // Input valid signal
    output logic [DWIDTH_ACCUMULATOR-1:0] result,   // Accumulated result output
    output logic valid_out                         // Output valid signal, indicates when result is ready
);
  // ----------------------------------------
  // - Local parameter definition
  // ----------------------------------------
  localparam DWIDTH_ACCUMULATOR = 2*DWIDTH + $clog2(N);

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
  // Already defined above.

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;    // Register to store intermediate multiplication result
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;   // Register to store accumulated result
  logic [$clog2(N):0] counter_reg;                   // Register to hold the value of the counter
  logic valid_out_s0, valid_out_s1, valid_out_s2;      // Intermediate Signals for valid output pipeline

  // ----------------------------------------
  // - Procedural blocks
  // ----------------------------------------

  // Stage 1 of the pipeline: Perform multiplication
  always @(posedge clk or negedge rstn) begin
     if (!rstn)
         mult_result_reg <= '0;
     else if (valid_i)
         mult_result_reg <= multiplicand * multiplier;
     // else: hold state
  end

  // Stage 2 of the pipeline: Accumulation logic
  always @(posedge clk or negedge rstn) begin
     if (!rstn)
         accumulation_reg <= '0;
     else if (valid_out_s1)
         accumulation_reg <= '0; // Reset accumulator after N valid inputs
     else if (valid_i)
         accumulation_reg <= accumulation_reg + mult_result_reg;
     // else: hold state
  end

  // N-bit counter to track the number of accumulations
  always @(posedge clk or negedge rstn) begin
     if (!rstn)
         counter_reg <= '0;
     else if (valid_out_s1)
         counter_reg <= '0; // Reset counter after output
     else if (valid_i)
         counter_reg <= counter_reg + 1;
     // else: hold state
  end

  // Register valid output for 2-stage pipeline
  always @(posedge clk or negedge rstn) begin
     if (!rstn) begin
         valid_out_s0 <= '0;
         valid_out_s1 <= '0;
         valid_out_s2 <= '0;
     end else begin
         valid_out_s0 <= (counter_reg == N-1); // Assert when N-1 valid inputs have been processed
         valid_out_s1 <= valid_out_s0;
         valid_out_s2 <= valid_out_s1;
     end
  end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
  // The following assignments generate the final output signals.
  assign result = accumulation_reg;
  assign valid_out = valid_out_s1 & ~valid_out_s2; // Pulse valid_out when rising edge of valid_out_s1

endmodule
