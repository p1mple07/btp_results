always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      out_data        <= {DATA_WIDTH{1'b0}};      
      counter_sub_out <= {NBW_COUNTER{1'b0}};
      counter_output  <= {NBW_COUNTER_OUTPUT{1'b0}};
   end
   else begin
      if(enable_output) begin
         if(counter_sub_out == SUB_BLOCKS*DATA_WIDTH/OUT_DATA_WIDTH - 1) begin
            out_data        <= out_data_aux[counter_sub_out][((counter_output%(DATA_WIDTH/OUT_DATA_WIDTH) + 1))*OUT_DATA_WIDTH-1-:OUT_DATA_WIDTH];
            counter_sub_out <= counter_sub_out + 1;
            counter_output  <= counter_output  + 1;
         end
         else begin
            out_data        <= {DATA_WIDTH{1'b0}};      
            counter_sub_out <= counter_sub_out;
            counter_output  <= counter_output;
         end
      end
   end
end
