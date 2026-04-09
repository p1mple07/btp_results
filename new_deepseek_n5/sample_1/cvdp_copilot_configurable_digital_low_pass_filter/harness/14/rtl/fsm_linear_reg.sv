module fsm_linear_reg(
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

    parameter DATA_WIDTH = 16;

    reg result1, result2;
    reg [DATA_WIDTH+1] done;

    state
        IDLE,
        COMPUTE,
        DONE
    endstate

    always_comb state = IDLE | COMPUTE | DONE
    case (state)
        IDLE:
            if (start) begin
                state = COMPUTE;
                result1 = 0;
                result2 = 0;
                done = 0;
            end
        COMPUTE:
            result1 = (w_in * x_in) >> 1;
            result2 = b_in + (x_in >> 2);
            state = DONE;
        DONE:
            result1 = 0;
            result2 = 0;
            done = 1;
            state = IDLE;
    endcase

    // Reset handling
    if (reset) begin
        result1 = 0;
        result2 = 0;
        done = 0;
        state = IDLE;
    end

    // Latency handling
    // After start is asserted, results are ready after 2 clock cycles
    // Done signal is asserted after 3 clock cycles
endmodule