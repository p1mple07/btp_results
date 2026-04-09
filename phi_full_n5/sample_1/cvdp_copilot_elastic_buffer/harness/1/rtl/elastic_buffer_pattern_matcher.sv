module elastic_buffer_pattern_matcher #(
   parameter WIDTH  = 16,
   parameter ERR_TOLERANCE  = 2
   )(
   input clk,
   input rst,
   input [WIDTH-1:0] i_data,
   input [WIDTH-1:0] i_pattern,
   output logic o_match
);

// Internal variables
reg [WIDTH-1:0] xor_data;

// Function to count the number of ones
function [$clog2(WIDTH):0] ones_count;
   input [WIDTH-1:0] i_data;
   begin
      ones_count = 0;
      for (int i = 0; i < WIDTH; i++) begin
         if (i_data[i] == 1)
            ones_count = ones_count + 1;
      end
   end
endfunction

// Matching logic
always_comb begin
   xor_data = i_data ^ i_pattern; // XOR operation to find mismatched bits
   err_count = ones_count(xor_data); // Count mismatched bits
   
   if (err_count <= ERR_TOLERANCE) begin
      o_match = 1; // Match found within error tolerance
   end else begin
      o_match = 0; // Match not found
   end
end

endmodule
