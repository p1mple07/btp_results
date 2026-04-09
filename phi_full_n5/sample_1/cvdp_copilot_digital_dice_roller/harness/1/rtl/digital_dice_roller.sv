module digital_dice_roller(
    input clk,
    input reset_n,
    input button,
    output reg [2:0] dice_value
);

    // State declaration
    typedef enum'(uinteger'([2:0])) state_t;
    typedef enum'(uinteger'([2:0])) next_state_t;
    state_t current_state, next_state;

    // State transition and counter logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            dice_value <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    // State transition logic
    always @(current_state or button) begin
        case (current_state)
            IDLE: begin
                if (button) begin
                    next_state = ROLLING;
                    dice_value <= 0;
                end else begin
                    next_state = IDLE;
                end
            end
            ROLLING: begin
                if (button) begin
                    next_state = ROLLING;
                    dice_value <= (dice_value + 1) & 7; // Ensure 3-bit counter value
                end else begin
                    next_state = IDLE;
                    dice_value <= dice_value;
                end
            end
        endcase
    end

endmodule
