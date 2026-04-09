always @(posedge clk or posedge reset) begin
    if(reset) begin
        present_state <= IDLE;
        system_status <= IDLE;
        current_floor_reg <= 0;        
    end else begin
        present_state <= next_state;
        system_status <= next_state;
        current_floor_reg <= current_floor_next;
        door_open_counter <= DOOR_OPEN_CYCLES; // Corrected non-blocking assignment
    end
end

always @(*) begin
    next_state = present_state;
    current_floor_next = current_floor_reg;
    
    case(present_state)
        IDLE: begin
            if(overload_detected) begin
                next_state = OVERLOAD_HALT;
            end else if(emergency_stop) begin
                next_state = EMERGENCY_HALT;
            end else if(call_requests_internal != 0)begin
                if(max_request > current_floor_reg)begin
                    next_state = MOVING_UP;
                end else if(min_request < current_floor_reg) begin
                    next_state = MOVING_DOWN;
                end
            end
        end
        // Added default case for EMERGENCY_HALT
        EMERGENCY_HALT: begin
            if (!emergency_stop) begin
                next_state = IDLE;
                current_floor_next = 0; // Optionally reset to ground floor
            end
            default: next_state = EMERGENCY_HALT; // Added default case
        end
        // ...
