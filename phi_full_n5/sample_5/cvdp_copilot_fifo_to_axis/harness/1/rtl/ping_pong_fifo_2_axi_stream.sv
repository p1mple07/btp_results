always_ff @(posedge i_axi_clk or posedge rst) begin
  if (rst) begin
    o_block_fifo_act   <= 1'b0;
    o_axi_valid        <= 1'b0;
    fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
    fifo_valid_buffer  <= 1'b0;
    fifo_last_buffer   <= 1'b0;
  end else begin
    if (i_block_fifo_rdy && i_axi_ready) begin
      fifo_data_buffer <= i_block_fifo_data;
      fifo_valid_buffer <= 1'b1;
      fifo_last_buffer <= i_block_fifo_last;
      o_block_fifo_act <= 1'b1;
      o_axi_data <= fifo_data_buffer;
      o_axi_last <= fifo_last_buffer;
      o_axi_valid <= fifo_valid_buffer;
    end else if (!i_block_fifo_rdy) begin
      o_block_fifo_act <= 1'b0;
      o_axi_valid <= 1'b0;
    end else if (!i_axi_ready) begin
      o_block_fifo_act <= 1'b0;
      o_axi_valid <= 1'b0;
    end
  end
end
