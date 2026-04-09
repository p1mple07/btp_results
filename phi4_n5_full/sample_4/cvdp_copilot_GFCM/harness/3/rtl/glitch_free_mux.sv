
always @(posedge clk1 or negedge rst_n) begin
    if (~rst_n) begin
         clk1_enable <= 0;
    end else begin
         clk1_enable <= ~clk2_enable & ~sel;
    end
end
