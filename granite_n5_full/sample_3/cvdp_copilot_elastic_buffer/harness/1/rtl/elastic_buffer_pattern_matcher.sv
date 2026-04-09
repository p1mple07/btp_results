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

   // Define internal variables
   logic [WIDTH-1:0]          xor_data ; // Result of XOR operation between i_data and i_pattern
   logic [ERR_TOLERANCE:0]    err_count; // Number of bits that are mismatched
   logic                        match    ; // Final output indicating a match or mismatch

   // Matching logic
   always_comb begin
      // Calculate the XOR result between i_data and i_pattern
      xor_data = i_data ^ i_pattern;

      // Calculate the number of errors based on the error tolerance
      err_count = $countones(xor_data) - 1;

      // Determine if there is an error
      match = (err_count <= ERR_TOLERANCE);
   end

   // Set the final output
   assign o_match = match;

endmodule