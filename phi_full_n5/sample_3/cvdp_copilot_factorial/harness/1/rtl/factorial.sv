module factorial_computation(
    input clk,
    input arst_n,
    input [4:0] num_in,
    input start,
    output reg busy,
    output reg [63:0] fact,
    output reg done
);

    typedef enum logic [1:0] {IDLE, BUSY, DONE} state_t;
    state_t state, next_state;

    // State transition logic
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            state <= IDLE;
        } else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= BUSY;
                        busy <= 1;
                        fact <= 1;
                    end
                end
                BUSY: begin
                    if (num_in == 0) begin
                        fact <= 1;
                        state <= DONE;
                    end else begin
                        fact <= fact * num_in;
                        state <= BUSY;
                    end
                end
                DONE: begin
                    busy <= 0;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

    // FSM outputs
    assign busy = state == BUSY;
    assign fact = state == BUSY ? fact : 1'b0;
    assign done = state == DONE;

endmodule
