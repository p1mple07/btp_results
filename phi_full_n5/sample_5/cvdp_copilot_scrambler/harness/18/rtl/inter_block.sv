always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      counter_sub_blocks <= {NBW_COUNTER{1'b0}};
      start_intra <= 0;
      for(int i = 0; i < SUB_BLOCKS; i++) begin
         in_data_reg[i] <= {DATA_WIDTH{1'b0}};
      end
   end
   else begin
      if(i_valid) begin
         in_data_reg[counter_sub_blocks] <= in_data;

         if(counter_sub_blocks == SUB_BLOCKS) begin
            counter_sub_blocks <= {NBW_COUNTER{1'b0}};
         end
         else begin
            start_intra <= 0;
            counter_sub_blocks <= counter_sub_blocks + 1;
         end
      end
      else if(counter_sub_blocks == SUB_BLOCKS) begin
         start_intra        <= 1;
         counter_sub_blocks <= {NBW_COUNTER{1'b0}};
      end
   end
end

always_ff @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      for(int i = 0; i < SUB_BLOCKS; i++) begin
         out_data_intra_block_reg[i] <= {DATA_WIDTH{1'b0}};
      end
   end
   else begin
      if(start_intra) begin
         for(int i = 0; i < SUB_BLOCKS; i++) begin
            out_data_intra_block_reg[i] <= out_data_intra_block[i];
         end
      end
   end
end
