always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      out_data        <= {DATA_WIDTH{1'b0}};      
      counter_sub_out <= {NBW_COUNTER_SUB_OUT{1'b0}};
      counter_output  <= {NBW_COUNTER_OUTPUT{1'b0}};     
   end
   else begin
      counter_sub_out <= counter_sub_out + 1;
      counter_output  <= counter_output  + 1;
      out_data        <= out_data_aux[counter_sub_out][(counter_output % 16) * 16 + (16 - (counter_output % 16))];
   end
end
