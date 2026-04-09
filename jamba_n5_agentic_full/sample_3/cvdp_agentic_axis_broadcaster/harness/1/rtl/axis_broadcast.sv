
always @(posedge clk or negedge rst_n) 
begin
    if (~rst_n) 
        s_axis_tready <= 0;
    else 
        s_axis_tready <= s_axis_tready_t1 ;
end
