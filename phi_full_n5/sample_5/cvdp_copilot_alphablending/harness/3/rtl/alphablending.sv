// State Transition Logic with non-blocking assignments
always @(posedge clk or posedge reset) begin
    if (reset) 
        state <= IDLE;
    else 
        state <= next_state;
end
