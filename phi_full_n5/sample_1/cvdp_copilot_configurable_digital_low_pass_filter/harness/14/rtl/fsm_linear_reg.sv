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

    // State declarations
    typedef enum logic [1:0] (IDLE, COMPUTE, DONE);
    typedef logic [1:0] state_t;
    logic [1:0] current_state, next_state;

    // State transition logic
    always_comb begin
        case (current_state)
            IDLE:
                if (start) begin
                    next_state = COMPUTE;
                    result1 <= 0;
                    result2 <= 0;
                end else begin
                    next_state = IDLE;
                end
            COMPUTE:
                result1 <= (w_in * x_in) >>> 1;
                result2 <= b_in + (x_in >>> 2);
                next_state = DONE;
                done <= 1;
            DONE:
                done <= 0;
                next_state = IDLE;
                result1 <= 0;
                result2 <= 0;
        endcase
    end

    // State machine
    always_ff @(posedge clk or posedge reset) begin
        if (reset) current_state <= IDLE;
        else current_state <= next_state;
    end

endmodule
