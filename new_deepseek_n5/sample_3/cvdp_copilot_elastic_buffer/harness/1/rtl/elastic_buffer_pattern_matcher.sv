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

// Internal variables
reg [WIDTH-1:0] xor_data;

// Matching logic
always_comb begin
   xor_data = i_data ^ i_pattern;
   err_count = ones_count(xor_data);
   o_match = (err_count < ERR_TOLERANCE) ? 1 : 0;
end

// Function to count the number of ones in a bit vector
function int ones_count;
   input [WIDTH-1:0] i_data;
   int count = 0;
   for (int i = 0; i < WIDTH; i++) {
      if (i_data[i]) {
         count++;
      }
   }
   return count;
endfunction

// End of module
endmodule