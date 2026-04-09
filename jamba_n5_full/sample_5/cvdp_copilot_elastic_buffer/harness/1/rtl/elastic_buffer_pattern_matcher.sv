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

// Internal function to count ones in an array
function [$clog2(WIDTH):0] ones_count([WIDTH-1:0] data);
   input [WIDTH-1:0] data;
   initial @(posedge clk);
   int cnt = 0;
   for (int i = 0; i < WIDTH; i++) begin
      if (data[i] == 1) cnt += 1;
   end
   return cnt;
endfunction

// Main always block
always_comb begin
   localvar xor_result = i_data ^ i_pattern;
   localvar mismatch_count = ones_count(xor_result);
   assign o_match = mismatch_count < ERR_TOLERANCE;
end

endmodule
