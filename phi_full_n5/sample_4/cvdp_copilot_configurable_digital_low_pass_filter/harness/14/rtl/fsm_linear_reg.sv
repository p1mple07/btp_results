module fsm_linear_reg #(parameter DATA_WIDTH = 16) (
    input clk,
    input reset,
    input start,
    input [DATA_WIDTH-1:0] x_in,
    input [DATA_WIDTH-1:0] w_in,
    input [DATA_WIDTH-1:0] b_in,
    output reg [2*DATA_WIDTH-1:0] result1,
    output reg [DATA_WIDTH:0] result2,
    output reg done
);

    typedef enum logic [1:0] {IDLE, COMPUTE, DONE} state_t;
    state_t state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            result1 <= 0;
            result2 <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE:
                    if (start) begin
                        next_state = COMPUTE;
                    end else next_state = IDLE;
                COMPUTE:
                    result1 <= w_in * x_in >>> 1;
                    result2 <= b_in + (x_in >>> 2);
                    next_state = DONE;
                DONE:
                    done <= 1;
                    next_state = IDLE;
            endcase
            state <= next_state;
        end
    end

    // Output logic
    always @* begin
        result1 <= {result1[DATA_WIDTH-1:0], 0}; // Prevent overflow
        result2 <= {result2[DATA_WIDTH-1:0], 0}; // Prevent overflow
        done <= (state == DONE);
    end

endmodule
