module hebbian_rule (
    input wire clk,
    input wire rst,
    input wire start,
    input wire a[3:0],
    input wire b[3:0],
    input wire gate_select[1:0],
    output reg w1, w2,
    output reg bias,
    output reg [3:0] present_state,
    output reg next_state
);

    // Internal state
    localparam STATE_RESET = 0;
    localparam STATE_CAPTURE = 1;
    localparam STATE_ASSIGN_TARGET = 2;
    localparam STATE_COMPUTE_DELTA = 3;
    localparam STATE_UPDATE_WEIGHTS = 4;
    localparam STATE_UPDATE_BIAS = 5;
    localparam STATE_LOOP = 6;
    localparam STATE_RETURN = 7;
    localparam STATE_FINISH = 8;
    localparam STATE_MAX = 10;

    reg [3:0] current_state;
    reg [3:0] next_state;
    reg [3:0] state_counter;
    reg [3:0] state_counter_reg;

    // Internal signals
    wire x1, x2;
    wire w1_new, w2_new, bias_new;
    wire delta_w1, delta_w2, delta_b;

    // Initialization
    always @(posedge clk) begin
        if (rst) begin
            current_state <= STATE_RESET;
            next_state <= STATE_CAPTURE;
            state_counter <= 0;
            state_counter_reg <= 0;
        end else begin
            if (start) begin
                current_state <= STATE_CAPTURE;
            end else begin
                case (current_state)
                    STATE_RESET: begin
                        current_state <= STATE_CAPTURE;
                    end
                    STATE_CAPTURE: begin
                        if (a != 0 || b != 0) begin
                            x1 <= a[3:0];
                            x2 <= b[3:0];
                        end
                        current_state <= STATE_ASSIGN_TARGET;
                    end
                    STATE_ASSIGN_TARGET: begin
                        current_state <= STATE_COMPUTE_DELTA;
                    end
                    STATE_COMPUTE_DELTA: begin
                        delta_w1 = x1 * current_state[1];
                        delta_w2 = x2 * current_state[1];
                        delta_b = current_state[1];
                        w1_new = w1 + delta_w1;
                        w2_new = w2 + delta_w2;
                        bias_new = bias + delta_b;
                        current_state <= STATE_UPDATE_WEIGHTS;
                    end
                    STATE_UPDATE_WEIGHTS: begin
                        w1 <= w1_new;
                        w2 <= w2_new;
                        bias <= bias_new;
                        current_state <= STATE_UPDATE_BIAS;
                    end
                    STATE_UPDATE_BIAS: begin
                        w1 <= w1_new;
                        w2 <= w2_new;
                        bias <= bias_new;
                        current_state <= STATE_LOOP;
                    end
                    STATE_LOOP: begin
                        current_state <= next_state;
                    end
                    STATE_RETURN: begin
                        current_state <= STATE_RESET;
                    end
                endcase
            end
        end
    end

    always @(posedge clk) begin
        if (current_state == STATE_FINISH) begin
            next_state <= STATE_RETURN;
        end else begin
            next_state <= current_state;
        end
    end

endmodule
