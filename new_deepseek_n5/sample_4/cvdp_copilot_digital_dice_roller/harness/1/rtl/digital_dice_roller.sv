module digital_dice_roller (
    input clock,
    input reset_n,
    input button,
    output dice_value
);

    // FSM state: 0 = IDLE, 1 = ROLLING
    reg state = 0;
    // Counter value: 1-6
    reg [2:0] counter = 0;
    // Current dice value: 000-110 (0-6)
    reg [2:0] dice_value = 0;

    // State transition table
    always @(posedge clock or (reset_n & state)) begin
        case (state)
            0: 
                if (button) begin
                    state = 1;
                    counter = 1;
                    dice_value = 0;
                end
            1: 
                if (button) begin
                    counter = (counter + 1) % 7;
                end
                else begin
                    state = 0;
                    dice_value = counter;
                end
            endcase
        end
    end

    // Ensure counter wraps around after 6
    always @* begin
        if (reset_n) begin
            state = 0;
            counter = 0;
            dice_value = 0;
        end
    end
endmodule