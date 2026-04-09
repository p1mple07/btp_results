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
reg         xor_data [WIDTH-1:0];
reg         err_count;

// Matching logic
always_comb begin
   xor_data = i_data ^ i_pattern;
   err_count        = ones_count(xor_data);
   o_match = (err_count <= ERR_TOLERANCE - 1);
end

// Function to count number of ones
function [$clog2(WIDTH):0] ones_count;
   input [WIDTH-1:0] i_data;
   integer c = 0;
   
   for (integer i = 0; i < WIDTH; i = i + 1) begin
      if ((i_data >> i) & 1) c = c + 1;
   end
   return c;
endfunction
endmodule