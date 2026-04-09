module elastic_buffer_pattern_matcher #(
   parameter WIDTH        = 16,
   parameter ERR_TOLERANCE = 2  // This parameter is set as (Error Tolerance + 1)
)(
   input                         clk,
   input                         rst,
   input         [WIDTH-1:0]     i_data,
   input         [WIDTH-1:0]     i_pattern,
   output logic                  o_match
);

   // Internal signal declarations
   logic [WIDTH-1:0]  xor_data;
   logic [$clog2(WIDTH):0] err_count;

   // Synchronous logic: on every positive clock edge, compute the mismatch count
   // and update the match output. The design is reset synchronously.
   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
         o_match      <= 1'b0;
         xor_data     <= {WIDTH{1'b0}};
         err_count    <= { $clog2(WIDTH){1'b0} };
      end else begin
         // Compute the XOR between data and pattern to identify mismatched bits
         xor_data     <= i_data ^ i_pattern;
         // Count the number of '1's in the XOR result (mismatch bits)
         err_count    <= ones_count(xor_data);
         // If the number of mismatched bits is less than ERR_TOLERANCE,
         // declare a valid match (i.e. allowed mismatches = ERR_TOLERANCE - 1)
         o_match      <= (err_count < ERR_TOLERANCE) ? 1'b1 : 1'b0;
      end
   end

   // Function: ones_count
   // Counts the number of 1's in the input vector.
   function automatic [$clog2(WIDTH):0] ones_count;
      input [WIDTH-1:0] i_data;
      integer i;
      begin
         ones_count = 0;
         for (i = 0; i < WIDTH; i = i + 1) begin
            ones_count = ones_count + i_data[i];
         end
      end
   endfunction

endmodule