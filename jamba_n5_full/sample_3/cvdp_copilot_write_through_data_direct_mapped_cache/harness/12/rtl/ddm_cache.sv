
always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          for (i = 0; i < 64; i = i + 1) begin
              d_valid[i] <= 0;
          end
      end else if (cache_write) begin
          d_valid[index] = 1;  
      end
  end
