module fsm_linear_reg (
    input clock,
    input reset,
    input start,
    input x_in,
    input w_in,
    input b_in,
    output result1,
    output result2,
    output done
);

    // State variables
    reg state = IDLE;
    reg [state] next_state;

    // State transition table
    table state transition_table = 
        IDLE, IDLE,
        IDLE, DONE,
        IDLE, IDLE,
        DONE, DONE,
        DONE, IDLE,
        DONE, DONE,
        IDLE, DONE,
        IDLE, IDLE,
        DONE, DONE,
        DONE, DONE,
        IDLE, IDLE,
        DONE, DONE,
        DONE, DONE,
        IDLE, IDLE,
        DONE, DONE,
        DONE, DONE
    ;

    // State transition logic
    case (state, start)
        IDLE, 1: next_state = transition_table[state + 2*start];
        DONE, _ : next_state = transition_table[state + 2*start];
    endcase

    // Computation logic
    always @* begin
        if (start) begin
            // Compute result1 = w_in * x_in >>> 1
            result1 = (w_in * x_in) >> 1;
            
            // Compute result2 = b_in + (x_in >>> 2)
            result2 = b_in + (x_in >> 2);
            
            // Transition to DONE state after 3 clock cycles
            next_state = transition_table[state + 2*start + 3];
        end
    end

    // Reset logic
    if (reset) begin
        result1 = 0;
        result2 = 0;
        done = 0;
        next_state = IDLE;
    end

    // Output the results
    result1;
    result2;
    done;

    // Latency handling
    delay #2 (result1, result2);
    delay #3 (done);

    // Ensure proper state transitions
    state = next_state;
endmodule