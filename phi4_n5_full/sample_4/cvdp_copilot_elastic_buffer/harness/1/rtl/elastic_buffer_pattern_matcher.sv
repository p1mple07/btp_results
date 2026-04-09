module elastic_buffer_pattern_matcher #(
   parameter WIDTH       = 16,
   parameter ERR_TOLERANCE = 2  // This parameter is set as (Allowed Mismatches + 1)
   )(
   input                         clk,       // Clock input
   input                         rst,       // Active high synchronous reset
   input         [WIDTH-1:0]     i_data,    // Input data to be matched
   input         [WIDTH-1:0]     i_pattern, // Pattern to be matched against
   output logic                  o_match    // Output indicating a match (1) or not (0)
);

   // Internal signals
   logic [WIDTH-1:0] xor_data;
   logic [$clog2(WIDTH):0] err_count;

   // Combinational logic: compute the XOR of input data and pattern, then count the number of ones (mismatches)
   always_comb begin
      xor_data  = i_data ^ i_pattern;
      err_count = ones_count(xor_data);
   end

   // Synchronized output logic: register the match result on the rising edge of clk
   always_ff @(posedge clk or posedge rst) begin
      if (rst)
         o_match <= 1'b0;
      else
         // If the number of mismatched bits is less than ERR_TOLERANCE, declare a match.
         o_match <= (err_count < ERR_TOLERANCE) ? 1'b1 : 1'b0;
   end

   // Function to count the number of ones in the input data.
   // ERR_TOLERANCE is defined as (Allowed Mismatches + 1) per requirement.
   function automatic [$clog2(WIDTH):0] ones_count;
      input [WIDTH-1:0] data;
      integer i;
      begin
         ones_count = 0;
         for (i = 0; i < WIDTH; i = i + 1) begin
            ones_count = ones_count + data[i];
         end
      end
   endfunction

endmodule