always_ff @(posedge w_clk, posedge w_rst) begin
  if (w_rst) begin
    w_count_bin <= 0;
    w_ptr       <= 0;
  end else begin
    if (!w_full && push) begin
      mem[w_ptr] <= w_data;
      w_ptr <= w_ptr + 1;
      w_count_bin <= w_count_bin + 1;
      w_full <= w_count_bin == DEPTH;
    end
  end
end

always_ff @(posedge r_clk, posedge r_rst) begin
  if (r_rst) begin
    r_count_bin <= 0;
    r_ptr       <= 0;
  end else begin
    if (!r_empty && pop) begin
      r_data <= mem[r_ptr];
      r_ptr <= r_ptr - 1;
      r_count_bin <= r_count_bin + 1;
      r_empty <= r_count_bin == wq2_rptr;
    end
  end
end

always_ff @(posedge r_clk or posedge r_rst) begin
  if (r_rst) begin
    r_empty <= 1;
  end else begin
    wq2_rptr <= r_count_bin;
    rq2_wptr <= wq2_rptr;
    wq2_rptr <= {wq2_rptr[0], ~wq2_rptr[1]};
    rq2_wptr <= {rq2_wptr[0], ~rq2_wptr[1]};
  end
end
