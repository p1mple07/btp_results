always_ff @(posedge w_clk, posedge w_rst) begin
  if (w_rst) begin
    w_count_bin <= 0;
    w_ptr       <= 0;
    r_count_bin <= 0;
    r_ptr       <= 0;
  end
  else begin
    if (push && !w_full) begin
      mem[w_ptr] <= w_data;
      w_count_bin <= w_count_bin + 1'b1;
      w_ptr <= w_ptr + 1'b1;
      wq2_rptr <= gray_code(w_ptr);
    end
    if (w_count_bin == DEPTH) begin
      w_full <= 1'b1;
    end
  end
end

always_ff @(posedge r_clk, posedge r_rst) begin
  if (r_rst) begin
    r_empty <= 1'b1;
    r_ptr       <= 0;
  end
  else begin
    if (pop && !r_empty) begin
      r_data <= mem[r_ptr];
      r_count_bin <= r_count_bin + 1'b1;
      r_ptr <= r_ptr - 1'b1;
      rq2_wptr <= gray_code(r_ptr);
    end
    if (r_count_bin == rq2_wptr) begin
      r_empty <= 1'b0;
    end
  end
end

function logic [DATA_WIDTH-1:0] gray_code(input logic [$clog2(DEPTH):0] binary_value);
  logic [$clog2(DEPTH):0] gray;
  gray = binary_value ^ (binary_value << 1);
  return gray;
endfunction
