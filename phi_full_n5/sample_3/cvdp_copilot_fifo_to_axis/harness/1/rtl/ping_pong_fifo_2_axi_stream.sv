always_ff @(posedge i_axi_clk or posedge rst) begin
  if (rst) begin
    o_block_fifo_act   <= 1'b0;
    o_axi_valid        <= 1'b0;
    fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
    fifo_valid_buffer  <= 1'b0;
    fifo_last_buffer   <= 1'b0;
  end else begin
    // Read FIFO data if ready
    if (i_block_fifo_rdy) begin
      fifo_data_buffer <= i_block_fifo_data;
      fifo_last_buffer <= i_block_fifo_last;
      fifo_valid_buffer <= 1'b1;
    end else begin
      // Hold data if FIFO is not ready
      fifo_valid_buffer <= 1'b0;
    end

    // Transfer data to AXI Stream if both FIFO and AXI are ready
    if (fifo_valid_buffer && i_axi_ready) begin
      o_axi_data <= fifo_data_buffer;
      o_axi_last <= fifo_last_buffer;
      o_axi_valid <= 1'b1;
      o_block_fifo_stb <= 1'b1;
      i_axi_user <= i_axi_user;
    end else begin
      // Hold AXI Stream data if AXI is not ready
      o_axi_valid <= 1'b0;
      o_block_fifo_act <= 1'b0;
    end
  end
end
