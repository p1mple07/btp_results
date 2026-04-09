module fsm_linear_reg #(
    parameter DATA_WIDTH = 16
) (
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

    reg current_state;
    reg next_state;
    reg done_high;

    initial begin
        current_state = IDLE;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state = IDLE;
            result1 <= 0;
            result2 <= 0;
            done <= 0;
            next_state = IDLE;
        end else begin
            case (current_state)
                IDLE: begin
                    if (start) begin
                        next_state = COMPUTE;
                    end
                    done_high = 1'b0;
                end
                COMPUTE: begin
                    result1 = w_in * x_in >>> 1;
                    result2 = b_in + (x_in >>> 2);
                    done_high = 1'b1;
                end
                DONE: begin
                    done <= 1'b0;
                    next_state = IDLE;
                end
            endcase
        end
    end

    assign result1 = (current_state == COMPUTE) ? result1 : 0;
    assign result2 = (current_state == COMPUTE) ? result2 : 0;
    assign done = (current_state == DONE) ? 1'b1 : 1'b0;

endmodule
