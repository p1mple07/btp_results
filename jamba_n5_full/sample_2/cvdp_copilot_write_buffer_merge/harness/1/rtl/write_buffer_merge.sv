
always_ff @(posedge clk) begin
  if (srst)
    base_addr <= '0;
  else begin
    // compute base_addr: take the MSBs of wr_addr_in, ignoring the LSBs determined by $clog2(BUFFER_DEPTH)
    base_addr <= wr_addr_in[INPUT_ADDR_WIDTH-1 - ($clog2(BUFFER_DEPTH) - 1) : 0];
  end
end
