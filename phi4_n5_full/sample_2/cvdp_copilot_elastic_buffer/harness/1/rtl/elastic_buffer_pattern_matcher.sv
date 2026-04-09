module elastic_buffer_pattern_matcher #(
   parameter WIDTH        = 16,
   parameter ERR_TOLERANCE = 2  // Note: ERR_TOLERANCE = (allowed mismatches) + 1
)(
   input                         clk,      // clock input
   input                         rst,      // Active high synchronous reset
   input         [WIDTH-1:0]     i_data,   // input data to be matched
   input         [WIDTH-1:0]     i_pattern, // pattern to be matched against
   output logic                  o_match    // output indicating a match between the pattern and i_data.
);

   // Internal signals
   logic [WIDTH-1:0] xor_data;
   // The return width of ones_count is defined as [$clog2(WIDTH):0]
   logic [$clog2(WIDTH):0] err_count;

   // Calculate XOR of i_data and i_pattern and count the number of ones
   always_comb begin
      xor_data   = i_data ^ i_pattern;
      err_count  = ones_count(xor_data);
   end

   // Synchronized output register: 1 clock cycle latency
   always_ff @(posedge clk or posedge rst) begin
      if (rst)
         o_match <= 1'b0;
      else
         o_match <= (err_count < ERR_TOLERANCE) ? 1'b1 : 1'b0;
   end

   // Function: ones_count
   // Counts the number of 1's in the input data.
   function [$clog2(WIDTH):0] ones_count;
      input [WIDTH-1:0] i_data;
      integer count;
      begin
         count = 0;
         for (int i = 0; i < WIDTH; i++) begin
            if (i_data[i])
               count++;
         end
         ones_count = count;
      end
   endfunction

endmodule