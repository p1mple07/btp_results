always_ff @(posedge w_clk, posedge w_rst) begin
  if (w_rst) begin
    w_count_bin <= 0;
    w_ptr       <= 0;
    r_count_bin <= 0;
    r_ptr       <= 0;
    r_empty     <= 1;
    w_full      <= 0;
  end
  else begin
    if (push && !w_full) begin
      mem[w_ptr] <= w_data;
      w_ptr <= w_ptr + 1;
      w_count_bin <= w_count_bin + 1;
      r_empty <= 0;
      w_full <= 0;
    end
  end
end

always_ff @(posedge r_clk, posedge r_rst) begin
  if (r_rst) begin
    r_count_bin <= 0;
    r_ptr       <= 0;
  end
  else begin
    if (pop && !r_empty) begin
      r_data <= mem[r_ptr];
      r_ptr <= r_ptr - 1;
      r_count_bin <= r_count_bin + 1;
      wq2_rptr <= r_ptr ^ w_ptr;
      r_empty <= 0;
      w_full <= (r_count_bin == wq2_rptr) ? 1 : 0;
    end
  end
end

always_ff @(posedge r_clk or posedge r_rst) begin
  if (r_rst) begin
    r_empty <= 1;
  end
  else begin
    if (r_count_bin == wq2_rptr) begin
      w_full <= 1;
    end
  end
end
