module elastic_buffer_pattern_matcher #(
    parameter int WIDTH        = 16,
    parameter int NUM_PATTERNS = 4
)(
    input  logic                              clk,                // Clock input
    input  logic                              rst,                // Active high synchronous reset
    input logic                               i_valid,            // Input data valid signal
    input  logic [WIDTH:0]                  i_data,             // Input data to be matched
    // Flattened array of patterns: each pattern is WIDTH bits wide.
    input  logic [NUM_PATTERNS*WIDTH:0]     i_pattern,          
    // Flattened array of masks: each mask is WIDTH bits wide (1 = compare; 0 = don't care).
    input  logic [NUM_PATTERNS*WIDTH:0]     i_mask,             
    input  logic [$clog2(WIDTH+1)-1:0]        i_error_tolerance,  // Runtime configurable error tolerance
     output logic                              o_valid,            // Output valid signal
    output logic [NUM_PATTERNS-1:0]           o_match             // Match output for each pattern
);
   logic [1:0] o_valid_reg;
   // ----------------------------------------------------------------
   // Pipeline Stage 1: Compute Masked Differences
   // ----------------------------------------------------------------
   logic [WIDTH-1:0] diff_pipe1 [NUM_PATTERNS-1:0];
   // ----------------------------------------------------------------
   // Pipeline Stage 2: Count Mismatches Using a Popcount Function
   // ----------------------------------------------------------------
   logic [$clog2(WIDTH+1)-1:0] error_count_pipe2 [NUM_PATTERNS-1:0];
   logic [$clog2(WIDTH+1)-1:0] error_count_pipe3 [NUM_PATTERNS-1:0];
   // ----------------------------------------------------------------
   // Signals for popcount implementation
   logic [WIDTH-1:0] count管 [NUM_PATTERNS*WIDTH:0];
   logic [WIDTH-1:0] sum管 [NUM_PATTERNS:0];
   // ----------------------------------------------------------------
   always_ff @(posedge clk) begin
      if (rst) begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            diff_pipe1[j] <= (i_data ^ i_pattern[j*WIDTH +: WIDTH]) & i_mask[j*WIDTH +: WIDTH];
         end
      end else begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            // Count the number of 1's (mismatches) in each diff vector using a loop
            count管[j] = 0;
            for (int k = 0; k < WIDTH; k++) begin
               count管[j] <= count管[j] + (diff_pipe1[j][k] & 1);
            end
            sum管[j] = count管[j];
         end
      end
   end
   // ----------------------------------------------------------------
   // Pipeline Stage 3: Compare Error Count with Runtime Tolerance
   // ----------------------------------------------------------------
   always_comb begin
      for (int j = 0; j < NUM_PATTERNS; j++) begin
         o_match[j] = (sum管[j] <= i_error_tolerance);
      end
   end
   // ----------------------------------------------------------------
   // Valid pipeline
   // ----------------------------------------------------------------
   always_ff @(posedge clk) begin
      if (rst)
         {o_valid, o_valid_reg} <= '0;
      else
         {o_valid, o_valid_reg} <= {o_valid_reg, i_valid};
   end
endmodule