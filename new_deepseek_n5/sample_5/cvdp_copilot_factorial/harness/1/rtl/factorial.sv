// FSM for Factorial Calculation
always_ff @(posedge clk or falling edge arst_n) begin
    if (start && num_in) begin
        state = BUSY;
        busy = 1;
        done = 0;
        result = 1;
        temp = num_in;
        cycles = 0;
    end else if (state == BUSY) begin
        if (cycles < num_in) begin
            result = result * (temp + 1);
            temp = temp + 1;
            cycles = cycles + 1;
            busy = 1;
        end else if (cycles == num_in) begin
            state = DONE;
            busy = 0;
            done = 1;
        end
    end else if (state == DONE) begin
        busy = 0;
        done = 0;
    end
end

// Assignments for outputs
assign fact = result;