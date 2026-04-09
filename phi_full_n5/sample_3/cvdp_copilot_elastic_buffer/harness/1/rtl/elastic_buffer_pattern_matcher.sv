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

   // Declare internal variables
   logic [WIDTH-1:0] xor_data;

   // Matching logic
   always_comb begin
      // Calculate the XOR between i_data and i_pattern
      xor_data = i_data ^ i_pattern;

      // Calculate the number of mismatched bits
      err_count        = ones_count(xor_data);

      // Set the final output based on the error tolerance
      if (err_count <= ERR_TOLERANCE) begin
         o_match = 1;
      end else begin
         o_match = 0;
      end
   end

// The following function counts the number of ones.
function [$clog2(WIDTH):0] ones_count;
   input [WIDTH-1:0] i_data;
   
   // Calculate the number of ones in i_data
   ones_count = i_data.count_ones();

endfunction

endmodule
