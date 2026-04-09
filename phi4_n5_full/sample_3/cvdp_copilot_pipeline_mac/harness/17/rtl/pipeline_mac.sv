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
  // Calculate accumulator width to avoid overflow:
  // Maximum multiplication result is 2*DWIDTH bits and accumulating N products requires an extra
  // ceil(log2(N)) bits. Hence, DWIDTH_ACCUMULATOR = 2*DWIDTH + $clog2(N).
  localparam DWIDTH_ACCUMULATOR = 2*DWIDTH + $clog2(N);

  // ----------------------------------------
  // - Interface Definitions
  // ----------------------------------------
  input  logic clk;                                // Clock signal
  input  logic rstn;                               // Active low reset signal
  input  logic [DWIDTH-1:0] multiplicand;          // Input multiplicand
  input  logic [DWIDTH-1:0] multiplier;            // Input multiplier
  input  logic valid_i;                            // Input valid signal
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
  logic valid_out_s0, valid_out_s1, valid_out_s2;      // Intermediate signals for valid output staging
  logic valid_i_s1;                                  // Intermediate signal for input valid (not used further)

  // ----------------------------------------
  // - Procedural blocks
  // ----------------------------------------

  // Stage 1 of the pipeline: Perform multiplication
  always @(posedge clk or negedge rstn) begin
     if (!rstn)
         mult_result_reg <= '0;
     else if (valid_i)
         mult_result_reg <= multiplicand * multiplier;
     else
         mult_result_reg <= mult_result_reg;
  end

  // Stage 2 of the pipeline: Accumulation logic
  always @(posedge clk or negedge rstn) begin
     if (!rstn)
         accumulation_reg <= '0;
     else if (accumulator_rst)
         accumulation_reg <= '0;
     else if (valid_i)
         accumulation_reg <= accumulation_reg + mult_result_reg;
     else
         accumulation_reg <= accumulation_reg;
  end

  // N-bit counter to track the number of accumulations
  always @(posedge clk or negedge rstn) begin
     if (!rstn)
         counter_reg <= '0;
     else if (count_rst)
         counter_reg <= '1;
     else if (valid_i)
         counter_reg <= counter_reg + '1;
     else
         counter_reg <= counter_reg;
  end

  // Register valid output for 2-stage pipeline
  always @(posedge clk or negedge rstn) begin
     if (!rstn) begin
         valid_out_s1 <= '0;
         valid_out_s2 <= '0;
     end else begin
         valid_out_s1 <= valid_out_s0;
         valid_out_s2 <= valid_out_s1;
     end
  end

  // ----------------------------------------
  // - Combinational Assignments
  // ----------------------------------------
  assign counter = count_rst ? '1 : (valid_i ? (counter_reg + '1) : counter_reg);
  assign valid_out_s0 = (counter_reg == N-1);    // Assert when N accumulations are done
  assign count_rst      = valid_out_s1;            // Reset counter after N accumulations
  assign accumulator_rst = valid_out_s1;            // Reset accumulator after N accumulations
  assign result         = accumulation_reg;        // Output final accumulated result
  assign valid_out      = valid_out_s1 & ~valid_out_s2; // Valid output asserted for one cycle

endmodule