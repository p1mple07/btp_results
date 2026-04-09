module digital_dice_roller (
    input clk,
    input reset_n,
    input button,
    output reg [2:0] dice_value
);

    // State declaration
    typedef enum'(int i) {IDLE, ROLLING} State_t;
    State_t current_state, next_state;

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            dice_value <= 3'b000;
        end else begin
            current_state <= next_state;
        end
    end

    // State transition function
    function State_t next_state(State_t current_state, input button);
        if (current_state == IDLE) begin
            if (button) next_state = ROLLING;
            else next_state = IDLE;
        end else if (current_state == ROLLING) begin
            if (button) next_state = ROLLING;
            else next_state = IDLE;
        end
    end

    // FSM implementation
    always @(*) begin
        next_state = next_state(current_state, button);
        case (next_state)
            IDLE: begin
                dice_value <= 3'b000;
            end
            ROLLING: begin
                if (counter == 6'b011111) begin
                    counter <= 3'b000;
                end else begin
                    counter <= counter + 1'b1;
                end
                dice_value <= counter;
            end
        endcase
    end

    // Counter for rolling
    reg [2:0] counter = 3'b000;

endmodule
