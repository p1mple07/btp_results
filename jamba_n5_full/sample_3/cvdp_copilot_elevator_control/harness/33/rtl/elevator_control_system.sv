
always @(posedge clk or posedge reset) begin
    if(reset)begin
        present_state <= IDLE;
        system_status <= IDLE;
        current_floor_reg <= 0;        
    end else begin
        present_state <= next_state;
        system_status <= next_state;
        current_floor_reg <= current_floor_next;
    end
end
