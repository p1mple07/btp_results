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

    // State variable
    enum state_t = 0;
    reg state;

    // State transitions
    always_ff @* begin
        case (state)
            IDLE: 
                if (start) begin
                    state = COMPUTE;
                end
            COMPUTE: 
                // Compute result1 = w_in * x_in >>> 1
                result1 = (w_in * x_in) >> 1;
                // Compute result2 = b_in + (x_in >>> 2)
                result2 = b_in + (x_in >> 2);
                state = DONE;
            DONE: 
                done = 1;
                // Wait for 1 clock cycle
                state = IDLE after 1;
        endcase
    end

    // Reset handling
    always begin
        if (reset) begin
            result1 = 0;
            result2 = 0;
            done = 0;
            state = IDLE;
        end
    end

    // Latency handling
    timescale 2ns;

endmodule