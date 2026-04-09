module elastic_buffer_pattern_matcher #(
   parameter WIDTH  = 16,
   parameter ERR_TOLERANCE  = 2
   )(
   input                         clk     , // clock input
   input                         rst     , // Active high synchronous reset
   input         [WIDTH-1:0]     i_data  , // input data to be matched
   input         [WIDTH-1:0]     i_pattern, // pattern to be matched against
   output logic                  o_match    // output indicating a match between the pattern and i_data.
);

   logic [WIDTH-1:0] xor_data;
   logic [ERR_TOLERANCE:0] err_count;

   always_comb begin
      xor_data = i_data ^ i_pattern;
      
      err_count = { ERR_TOLERANCE{1'b0} };
      for (int i=0; i<WIDTH; ++i) begin
         if (i_data[i]!= i_pattern[i])
            err_count++;
      end

      if (err_count <= ERR_TOLERANCE)
         o_match = 1'b1;
      else
         o_match = 1'b0;
   end
endmodule