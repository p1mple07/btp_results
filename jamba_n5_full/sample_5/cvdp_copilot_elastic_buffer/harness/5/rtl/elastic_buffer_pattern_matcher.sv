module elastic_buffer_pattern_matcher #(
    parameter int WIDTH        = 16,                              // Represents the Width of the input data,pattern and mask signals.
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
   // ---------------------------------------------------------------------------
   // Pipeline Stage 1: Compute Masked Differences
   //
   // For each pattern, compute the bitwise difference between i_data and
   // the corresponding pattern slice, then mask off "don't care" bits.
   //---------------------------------------------------------------------------
   logic [WIDTH-1:0] diff_pipe1 [NUM_PATTERNS-1:0];
   logic [WIDTH-1:0] diff_pipe2 [NUM_PATTERNS-1:0];

   always_ff @(posedge clk) begin
      if (rst) begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            diff_pipe1[j] <= '0;
         end
      end else begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            // Extract the j-th pattern and mask slice from the flattened inputs.
            diff_pipe1[j] <= (i_data ^ i_pattern[j*WIDTH +: WIDTH]) & i_mask[j*WIDTH +: WIDTH];
         end
      end
   end

   //---------------------------------------------------------------------------
   // Pipeline Stage 2: Count Mismatches Using a Popcount Function
   //
   // Count the number of 1's (mismatches) in each diff vector.
   //---------------------------------------------------------------------------
   logic [$clog2(WIDTH+1)-1:0] error_count_pipe2 [NUM_PATTERNS-1:0];
   logic [$clog2(WIDTH+1)-1:0] error_count_pipe3 [NUM_PATTERNS-1:0];

   // Popcount function: counts the number of '1's in a vector.
   function automatic [$clog2(WIDTH+1)-1:0] popcount(input logic [WIDTH-1:0] vector);
      int k;
      popcount = 0;
      for (k = 0; k < WIDTH; k++) begin
         popcount += {{$clog2(WIDTH+1)-1{1'b0}}, vector[k]};
      end
   endfunction

   always_ff @(posedge clk) begin
      if (rst) begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            error_count_pipe2[j] = '0;
			i_mask[j] <= '0;
   o_match[j] <= '0;
         end
      end else begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            error_count_pipe2[j] <= popcount(diff_pipe1[j]);
         end
      end
   end

   //---------------------------------------------------------------------------
   // Pipeline Stage 3: Compare Error Count with Runtime Tolerance
   //
   // Assert the match signal for each pattern if the number of mismatches is
   // less than or equal to the error tolerance.
   //---------------------------------------------------------------------------
   always_comb begin
      for (int j = 0; j < NUM_PATTERNS; j++) begin
		o_match[j] = (error_count_pipe2[j] <= i_error_tolerance);
      end
   end

   //---------------------------------------------------------------------------
   // Valid pipeline
   //---------------------------------------------------------------------------
   always_ff @(posedge clk) begin
      if (rst)
         {o_valid, o_valid_reg} <= '0;
      else
         {o_valid, o_valid_reg} <= {o_valid_reg, i_valid}; 
   end
endmodule
