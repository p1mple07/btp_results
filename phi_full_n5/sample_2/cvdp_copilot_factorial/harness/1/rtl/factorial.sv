module factorial #(parameter WIDTH = 64) (
    input clk,
    input arst_n,
    input [4:0] num_in,
    input start,
    output reg busy,
    output reg [WIDTH-1:0] fact,
    output reg done
);

    typedef enum logic [1:0] {IDLE, BUSY, DONE} state_t;
    state_t state, next_state;

    // State transition table
    // Next state | Current state | Start | Arst_n | Num_in | Busy | Done | Next state
    // ---------------------------------------------------------------------------------
    // BUSY      | IDLE           | 1     | 0      | 1      | 0    | 0    | BUSY
    // BUSY      | BUSY           | 0     | 0      | 0      | 1    | 0    | DONE
    // DONE      | IDLE           | 0     | 1      | 0      | 0    | 1    | IDLE

    // State transition logic
    always_ff @(posedge clk or posedge arst_n) begin
        case ({state, start, arst_n, num_in})
            {IDLE, 1, 0, 1'b1} : begin
                state <= BUSY;
                busy <= 1'b0;
                next_state <= BUSY;
            end
            {BUSY, 0, 0, 0'b0} : begin
                state <= DONE;
                busy <= 1'b1;
                next_state <= IDLE;
            end
            {DONE, 0, 1, 0'b0} : begin
                state <= IDLE;
                busy <= 1'b0;
                next_state <= DONE;
            end
            default : begin
                state <= IDLE;
                busy <= 1'b0;
                next_state <= IDLE;
            end
        endcase
    end

    // FSM state logic
    always @(posedge clk or posedge arst_n) begin
        if (arst_n) begin
            state <= IDLE;
            busy <= 1'b0;
            fact <= 1'b0;
            done <= 1'b0;
        end else if (state == IDLE) begin
            if (start) begin
                state <= BUSY;
                busy <= 1'b0;
                fact <= 1'b0;
                done <= 1'b0;
            end
        end else if (state == BUSY) begin
            if (num_in == 0) begin
                fact <= 1'b1; // Factorial of 0 is 1
                state <= DONE;
                busy <= 1'b0;
                done <= 1'b1;
            end else begin
                fact <= fact * num_in;
                state <= BUSY;
            end
        end else if (state == DONE) begin
            busy <= 1'b0;
            done <= 1'b0;
        end
    end

endmodule
