module low_power_channel;
  import work.sync_fifo::*;
  import work.low_power_ctrl::*;

  genvar int i;

  for (generate i = 0; i < 1; i=i+1) begin : inst_sync_fifo
    instantiate @(negedge clk) sync_fifo #(.DEPTH(8), .DATA_W(8));
  end

  instantiation #(.CLK(clk), .RST(reset)) of inst_sync_fifo;

  instantiation #(.CLK(clk), .RST(reset)) of low_power_ctrl;
endmodule
