
always_ff @(posedge clk) begin
   if (rst)
      {o_valid, o_valid_reg} <= '0;
   else
      {o_valid, o_valid_reg} <= {o_valid_reg, i_valid};
end
