module elastic_buffer_pattern_matcher #(
   parameter WIDTH  = 16,
   parameter ERR_TOLERANCE  = 2
   )(
   input                         clk      , // clock input
   input                         rst      , // Active high synchronous reset
   input         [WIDTH-1:0]     i_data   , // input data to be matched
   input         [WIDTH-1:0]     i_pattern, // pattern to be matched against
   output logic                  o_match    // output indicating a match between the pattern and i_data.
);

   // Internal function to count the number of 1s in a binary vector
   function [$clog2(WIDTH):0] ones_count(input [WIDTH-1:0] data);
      integer cnt = 0;
      for (int i = 0; i < WIDTH; i++) begin
         if (data[i] == 1) cnt += 1;
      end
      return cnt;
   endfunction

   // Internal variable to store the match decision
   reg o_match;

   // Always combinational block for the main logic
   always_comb begin
      int xor_data = i_data ^ i_pattern;
      int err_count = ones_count(xor_data);

      if (err_count < ERR_TOLERANCE) begin
         o_match = 1;
      end else if (err_count > ERR_TOLERANCE) begin
         o_match = 0;
      end
   end

endmodule
