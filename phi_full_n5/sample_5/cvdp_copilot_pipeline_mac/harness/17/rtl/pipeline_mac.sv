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
  
    // Calculate parameter DWIDTH_ACCUMULATOR to handle the result bit width to avoid overflow.
    // Assuming the maximum value for unsigned 16-bit multiplication is 65535, the accumulator
    // should be able to handle this value. Therefore, we need at least 17 bits to avoid overflow.
    parameter DWIDTH_ACCUMULATOR = $clog2(2) + $clog2(65535); // At least 17 bits to handle overflow

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
  logic [$clog2(N):0] counter;                       // Counter to track the number of accumulations
  logic [$clog2(N):0] counter_reg;                   // Register to hold the value of the counter
  logic count_rst, accumulator_rst;                  // Reset signals for counter and accumulator
  logic valid_out_s0,valid_out_s1,valid_out_s2;      // Intermediate Signals indicating that the valid output is ready
  logic valid_i_s1;                                  // Intermediate Signals indicating input valid signal
  // ----------------------------------------
  // - Procedural blocks
  // ----------------------------------------

  // Stage 1 of the pipeline: Perform multiplication
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      mult_result_reg <= 'b0;
      accumulation_reg <= 'b0;
    end else if (valid_i) begin
      mult_result_reg <= {mult_result_reg[DWIDTH-1:0], (multiplicand * multiplier) >> (DWIDTH - 1); }
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
      counter <= 'b0;
    end else if (valid_i) begin
      counter_reg <= counter_reg + 1;
      counter <= counter_reg;
    end
  end

  // Register valid output for 2-stage pipeline
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      valid_out_s0 <= 0;
      valid_out_s1 <= 0;
      valid_out_s2 <= 0;
    end else if (counter == N-1) begin
      valid_out_s0 <= 1;
      valid_out_s1 <= valid_out_s0;
      valid_out_s2 <= 0;
    end else begin
      valid_out_s0 <= valid_out_s1;
      valid_out_s1 <= valid_out_s0;
      valid_out_s2 <= valid_out_s1;
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
