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
  // Calculate accumulator width to safely hold the sum of N products.
  // Each multiplication produces a 2*DWIDTH result.
  // Accumulating N such products requires an extra log2(N) bits.
  localparam DWIDTH_ACCUMULATOR = 2*DWIDTH + $clog2(N);

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
  input  logic                        clk;                                // Clock signal
  input  logic                        rstn;                               // Active low reset signal
  input  logic [DWIDTH-1:0]           multiplicand;                       // Input multiplicand
  input  logic [DWIDTH-1:0]           multiplier;                         // Input multiplier
  input  logic                        valid_i;                            // Input valid signal
  output logic [DWIDTH_ACCUMULATOR-1:0] result;                             // Accumulated result output
  output logic                        valid_out;                          // Output valid signal

  // ----------------------------------------
  // - Internal signals
  // ----------------------------------------
  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;    // Register to store intermediate multiplication result
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;   // Register to store accumulated result
  logic [$clog2(N):0]          counter;               // Combinational counter (derived from counter_reg)
  logic [$clog2(N):0]          counter_reg;           // Register to hold the counter value
  logic                       count_rst, accumulator_rst;  // Reset signals for counter and accumulator
  logic                       valid_out_s0, valid_out_s1, valid_out_s2; // Intermediate valid output signals

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
  // The counter is updated only on valid input, except when a reset (count_rst) is asserted.
  assign counter = count_rst ? 'b1 : (valid_i & rstn ? (counter_reg + 'd1) : counter_reg);
  assign valid_out_s0 = (counter_reg == N-1);    // Assert when N valid inputs have been processed
  assign count_rst    = valid_out_s1;              // Reset counter after output is generated
  assign accumulator_rst = valid_out_s1;            // Reset accumulator after output is generated
  assign result       = accumulation_reg;          // Drive the final accumulated result
  assign valid_out    = valid_out_s1 & ~valid_out_s2; // Pulse valid_out on the rising edge of valid_out_s1

  // ----------------------------------------
  // - Procedural Blocks
  // ----------------------------------------

  // Stage 1 of the pipeline: Perform multiplication
  always @(posedge clk or negedge rstn) begin
     if (!rstn) begin
        mult_result_reg <= '0;
     end
     else if (valid_i) begin
        mult_result_reg <= multiplicand * multiplier;
     end
     else begin
        // Hold the previous multiplication result if valid_i is low
        mult_result_reg <= mult_result_reg;
     end
  end

  // Stage 2 of the pipeline: Accumulation logic
  always @(posedge clk or negedge rstn) begin
     if (!rstn) begin
        accumulation_reg <= '0;
     end
     else if (accumulator_rst) begin
        // Clear the accumulator after output is generated
        accumulation_reg <= '0;
     end
     else if (valid_i) begin
        accumulation_reg <= accumulation_reg + mult_result_reg;
     end
     else begin
        // Hold the current accumulated value if valid_i is low
        accumulation_reg <= accumulation_reg;
     end
  end

  // N-bit counter to track the number of accumulations
  always @(posedge clk or negedge rstn) begin
     if (!rstn) begin
        counter_reg <= '0;
     end
     else if (count_rst) begin
        counter_reg <= '0;
     end
     else if (valid_i) begin
        counter_reg <= counter_reg + 1;
     end
     else begin
        counter_reg <= counter_reg;
     end
  end

  // Register valid output for 2-stage pipeline
  always @(posedge clk or negedge rstn) begin
     if (!rstn) begin
        valid_out_s1 <= 0;
        valid_out_s2 <= 0;
     end
     else begin
        // Delay valid_out_s1 by one cycle to detect its rising edge
        valid_out_s2 <= valid_out_s1;
        if (valid_out_s0)
            valid_out_s1 <= 1;
        else
            valid_out_s1 <= 0;
     end
  end

endmodule