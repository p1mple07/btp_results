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
reg logic err_count;

// Matching logic
always_comb begin
   // Compute XOR of data and pattern
   err_count = 0;
   for (int i = 0; i < WIDTH; i++) begin
      if ((i_data[i] & !i_pattern[i])) err_count = err_count + 1;
      if ((!i_data[i] & i_pattern[i])) err_count = err_count + 1;
   end
   // Alternatively, can use: err_count = ones_count(xor_data);
end

// Final output
always_comb begin
   o_match = 1;
   if (err_count > ERR_TOLERANCE) o_match = 0;
end

// The following function counts the number of ones.
function [$clog2(WIDTH):0] ones_count;
   input [WIDTH-1:0] i_data;
   
   // Insert Code here to complete the function
   reg logic count = 0;
   for (int i = 0; i < WIDTH; i++) begin
      if (i_data[i]) count = count + 1;
   end
   return count;
endfunction
endmodule