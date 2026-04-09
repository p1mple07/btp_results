module fsm_linear_reg (
    input clk,
    input reset,
    input start,
    input x_in,
    input w_in,
    input b_in,
    output result1,
    output result2,
    output done
);

    reg state = IDLE;
    reg [DATA_WIDTH*2-1:0] result1;
    reg [DATA_WIDTH+1-1:0] result2;
    reg done_state;

    always_ff +pr result1, result2, done_state;

    initial state = IDLE;

    always @ (posedge clk or negedge reset) begin
        case (state)
            IDLE:
                if (reset) begin
                    result1 = 0;
                    result2 = 0;
                    done_state = IDLE;
                end else if (start) begin
                    state = COMPUTE;
                    done_state = IDLE;
                end
                else state = IDLE;
                end

            COMPUTE:
                if (reset) begin
                    result1 = 0;
                    result2 = 0;
                    done_state = IDLE;
                end else if (start) begin
                    // Compute result1 = w_in * x_in >>> 1
                    result1 = (w_in * x_in) >> 1;
                    
                    // Compute result2 = b_in + (x_in >>> 2)
                    result2 = b_in + (x_in >> 2);
                    
                    done_state = DONE;
                    delay #2 result1;
                    delay #3 done;
                end else 
                    done_state = DONE;
                end

            DONE:
                if (reset) begin
                    result1 = 0;
                    result2 = 0;
                    done_state = IDLE;
                end else if (start) begin
                    done = 1;
                    done_state = IDLE;
                end else 
                    done_state = DONE;
                end
        endcase
    end

    // Latency delays
    delay #2 result1;
    delay #3 done;
endmodule