always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n)
      valid_ff <= 1'b0;
   else 
      valid_ff <= i_valid;
   end
