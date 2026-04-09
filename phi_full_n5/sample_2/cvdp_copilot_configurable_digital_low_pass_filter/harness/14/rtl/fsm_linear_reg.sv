module fsm_linear_reg #(parameter DATA_WIDTH = 16) (
    input clk,
    input reset,
    input start,
    input logic [DATA_WIDTH-1:0] x_in,
    input logic [DATA_WIDTH-1:0] w_in,
    input logic [DATA_WIDTH-1:0] b_in,
    output logic [2*DATA_WIDTH-1:0] result1,
    output logic [DATA_WIDTH:0] result2,
    output done
);

    logic [DATA_WIDTH-1:0] temp_result1, temp_result2;
    logic [DATA_WIDTH-1:0] prev_x_in, prev_w_in, prev_b_in;

    // State declaration
    typedef enum logic [DATA_WIDTH-1:0] {IDLE, COMPUTE, DONE} state_t;
    state_t current_state, next_state;

    // State transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            temp_result1 <= 0;
            temp_result2 <= 0;
            prev_x_in <= x_in;
            prev_w_in <= w_in;
            prev_b_in <= b_in;
        end else begin
            case (current_state)
                IDLE:
                    if (start) begin
                        next_state <= COMPUTE;
                        temp_result1 <= 0;
                        temp_result2 <= 0;
                    end
                    else begin
                        next_state <= IDLE;
                    end
                COMPUTE:
                    temp_result1 <= (w_in * x_in) >>> 1;
                    temp_result2 <= b_in + (x_in >>> 2);
                    next_state <= DONE;
                DONE:
                    done <= 1;
                    temp_result1 <= 0;
                    temp_result2 <= 0;
            endcase
            current_state <= next_state;
        end
    end

    // Output logic
    always_comb begin
        result1 <= temp_result1;
        result2 <= (temp_result2 << DATA_WIDTH-1) | prev_b_in;
    end

endmodule
