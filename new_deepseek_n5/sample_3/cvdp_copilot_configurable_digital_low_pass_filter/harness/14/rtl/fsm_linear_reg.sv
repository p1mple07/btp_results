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

    parameter DATA_WIDTH = 16;

    reg state = IDLE;
    reg result1, result2, done;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state = IDLE;
            result1 = 0;
            result2 = 0;
            done = 0;
        else if (start) begin
            state = DONE;
        end
    end

    case (state)
        IDLE: begin
            if (start) begin
                state = COMPUTE;
            end
        end

        COMPUTE: begin
            // Compute result1 = w_in * x_in >>> 1
            result1 = (w_in * x_in) >> 1;
            // Compute result2 = b_in + (x_in >>> 2)
            result2 = b_in + (x_in >> 2);
            state = DONE;
        end

        DONE: begin
            done = 1;
            state = IDLE;
        end
    endcase
endmodule