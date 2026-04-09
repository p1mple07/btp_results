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

logic [WIDTH-1:0] xor_data ;
logic [ERR_TOLERANCE:0] err_count;

// Matching logic
always_comb begin
   err_count        = ones_count(xor_data);
   
   o_match           = (err_count <= ERR_TOLERANCE)? 1'b1 : 1'b0; 
   
end

// The following function counts the number of ones.
function [$clog2(WIDTH)-1:0] ones_count;
   input [WIDTH-1:0] i_data;

   // Insert Code here to complete the function

endfunction
endmodule