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

localparam ERR_TOLERANCE_USED = ERR_TOLERANCE + 1;

// Internal variables
reg [WIDTH-1:0] xor_data;
reg [WIDTH-1:0] o_match_val;

always_comb begin
   xor_data = i_data ^ i_pattern;
   err_count = ones_count(xor_data);
   o_match_val = err_count < ERR_TOLERANCE_USED;
end

// The following function counts the number of ones.
function [$clog2(WIDTH):0] ones_count([WIDTH-1:0] i_data);
   input [WIDTH-1:0] i_data;
   initial assign ones_count = 0;
   for (int i = 0; i < WIDTH; i++) begin
      if (i_data[i] == 1) ones_count++;
   end
   return ones_count;
endfunction

endmodule
