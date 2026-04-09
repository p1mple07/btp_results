
IDLE: begin
    if (start) begin
        next_state = ENCODE;
    end else begin
        next_state = IDLE;
    end
end
