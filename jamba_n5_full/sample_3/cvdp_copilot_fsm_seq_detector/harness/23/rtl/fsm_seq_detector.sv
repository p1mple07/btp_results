
always @ (posedge clk_in or posedge rst_in)
begin
    if (rst_in)
        cur_state <= S0;
    else
        cur_state <= next_state;
end
