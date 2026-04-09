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
   // Perform bitwise XOR to find mismatches
   xor_data = i_data ^ i_pattern;

   // Calculate the number of mismatched bits
   err_count        = ones_count(xor_data);

   // Check if the number of mismatches is within the tolerance
   if (err_count <= ERR_TOLERANCE) begin
      o_match = 1;
   end
   else begin
      o_match = 0;
   end
end

// The following function counts the number of ones.
function [$clog2(WIDTH):0] ones_count;
   input [WIDTH-1:0] i_data;
   
   // Initialize the count
   ones_count = 0;
   
   // Iterate over each bit and count the ones
   for (int i = 0; i < WIDTH; i++) begin
      if (i_data[i] == 1) begin
         ones_count = ones_count + 1;
      end
   end
endfunction

endmodule
