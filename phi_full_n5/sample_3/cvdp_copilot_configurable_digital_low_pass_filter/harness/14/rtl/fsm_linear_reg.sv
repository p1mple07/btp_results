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

    // State declaration
    typedef enum logic [1:0] {IDLE, COMPUTE, DONE} state_t;
    state_t state = IDLE;

    // Registers for outputs
    logic [2*DATA_WIDTH-1:0] next_result1;
    logic [DATA_WIDTH:0] next_result2;

    // State transition logic
    always_ff @(posedge clk or posedge reset) begin
        case (state)
            IDLE:
                if (start) begin
                    state <= COMPUTE;
                    next_result1 <= 0;
                    next_result2 <= 0;
                end else
                    state <= IDLE;
            COMPUTE:
                next_result1 = w_in * x_in >>> 1;
                next_result2 = b_in + (x_in >>> 2);
                state <= DONE;
            DONE:
                done <= 1;
                state <= IDLE;
            default:
                state <= IDLE;
        endcase
    end

    // Output logic
    always_comb begin
        result1 <= next_result1;
        result2 <= next_result2;
    end

    // Reset logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            result1 <= 0;
            result2 <= 0;
            done <= 0;
        end
    end

endmodule
