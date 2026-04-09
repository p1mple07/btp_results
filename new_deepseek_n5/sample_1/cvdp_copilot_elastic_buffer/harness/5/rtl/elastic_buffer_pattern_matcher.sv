module elastic_buffer_pattern_matcher #(
    parameter int WIDTH        = 16,
    parameter int NUM_PATTERNS = 4
)(
    input  logic                              clk,
    input  logic                              rst,
    input logic                               i_valid,
    input  logic [WIDTH:0]                  i_data,
    input  logic [NUM_PATTERNS*WIDTH:0]     i_pattern,
    input  logic [NUM_PATTERNS*WIDTH:0]     i_mask,
    input  logic [$clog2(WIDTH+1)-1:0]        i_error_tolerance,
    output logic                              o_valid,
    output logic [NUM_PATTERNS-1:0]           o_match
);
   logic [1:0] o_valid_reg;
   // ----------------------------------------------------------------------------- 
   // Pipeline Stage 1: Compute Masked Differences
   logic [WIDTH-1:0] diff_pipe1 [NUM_PATTERNS-1:0];
   // ----------------------------------------------------------------------------- 
   // Pipeline Stage 2: Count Mismatches Using a Popcount Function
   logic [$clog2(WIDTH+1)-1:0] error_count_pipe2 [NUM_PATTERNS-1:0];
   logic [$clog2(WIDTH+1)-1:0] error_count_pipe3 [NUM_PATTERNS-1:0];
   function automatic [$clog2(WIDTH+1)-1:0] popcount(input logic [WIDTH-1:0] vector);
      int k;
      popcount = 0;
      for (k = 0; k < WIDTH; k++) begin
         popcount += {$clog2(WIDTH+1)-1{1'b0}, vector[k]};
      end
   endfunction
   // ----------------------------------------------------------------------------- 
   // Pipeline Stage 3: Compare Error Count with Runtime Tolerance
   always_comb begin
      for (int j = 0; j < NUM_PATTERNS; j++) begin
         o_match[j] = (error_count_pipe2[j] <= i_error_tolerance);
      end
   end
   // ----------------------------------------------------------------------------- 
   // Valid pipeline
   always_ff @(posedge clk) begin
      if (rst) begin
         {o_valid, o_valid_reg} <= '0;
      else
         {o_valid, o_valid_reg} <= {o_valid_reg, i_valid};
      end
   end
endmodule