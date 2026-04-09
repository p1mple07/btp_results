module elastic_buffer_pattern_matcher #(
   parameter WIDTH  = 16,
   parameter ERR_TOLERANCE  = 2
) (
   input                         clk      , // clock input
   input                         rst      , // Active high synchronous reset
   input         [WIDTH-1:0]     i_data   , // input data to be matched
   input         [WIDTH-1:0]     i_pattern, // pattern to be matched against
   output logic                  o_match    // output indicating a match between the pattern and i_data.
);

// Internal function to count the number of 1-bits in a data vector
function [$clog2(WIDTH):0] ones_count([$clog2(WIDTH):0] i_data);
   integer cnt = 0;
   for (int i = 0; i < $clog2(i_data); i++) begin
      if (i_data[i] == 1) cnt++;
   end
   return cnt;
endfunction

// Internal variables
localparam ERR_THRESHOLD = ERR_TOLERANCE + 1;

// Always block driven by the clock
always_comb begin
   o_match = (rst ? 0 : 
               (ones_count(xor_data) < ERR_THRESHOLD) ? 1 : 0);
end

endmodule
