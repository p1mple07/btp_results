always_ff @(posedge clk) begin
   if (rst) begin
      for (int j = 0; j < NUM_PATTERNS; j++) begin
         diff_pipe1[j] <= '0;
         error_count_pipe2[j] <= '0;
         error_count_pipe3[j] <= '0;
         o_match[j] <= '0;
   end
   else begin
      for (int j = 0; j < NUM_PATTERNS; j++) begin
         diff_pipe1[j] <= (i_data ^ i_pattern[j*WIDTH +: WIDTH]) & i_mask[j*WIDTH +: WIDTH];
         error_count_pipe2[j] <= popcount(diff_pipe1[j]);
         o_match[j] <= (error_count_pipe2[j] <= i_error_tolerance);
   end
   end
end

always_comb begin
   o_valid <= o_valid_reg;
end
