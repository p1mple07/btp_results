module elastic_buffer_pattern_matcher #(
   parameter WIDTH         = 16,
   parameter ERR_TOLERANCE = 2  // ERR_TOLERANCE is set as (Error Tolerance + 1). Allowed mismatches = ERR_TOLERANCE - 1.
)(
   input                         clk,      // clock input
   input                         rst,      // Active high synchronous reset
   input         [WIDTH-1:0]     i_data,   // input data to be matched
   input         [WIDTH-1:0]     i_pattern,// pattern to be matched against
   output logic                  o_match   // output indicating a match between the pattern and i_data
);

   // Internal signals
   logic [WIDTH-1:0] xor_data;
   // Using the same width as defined in the ones_count function
   logic [$clog2(WIDTH):0] err_count;

   // Compute XOR of input data and pattern, then count the number of mismatched bits (ones)
   always_comb begin
      xor_data = i_data ^ i_pattern;
      err_count = ones_count(xor_data);
   end

   // Synchronized output: register the match result with 1 clock cycle latency
   always_ff @(posedge clk or posedge rst) begin
      if (rst)
         o_match <= 0;
      else
         // A valid match is declared if the number of mismatched bits is less than ERR_TOLERANCE
         o_match <= (err_count < ERR_TOLERANCE) ? 1'b1 : 1'b0;
   end

   // Function: Count the number of ones in the input vector.
   // Note: The return width is [$clog2(WIDTH):0] which is sufficient when WIDTH is a power of 2.
   function automatic [$clog2(WIDTH):0] ones_count;
      input [WIDTH-1:0] i_data;
      int unsigned count;
      count = 0;
      for (int j = 0; j < WIDTH; j++) begin
         if (i_data[j])
            count++;
      end
      ones_count = count;
   endfunction

endmodule