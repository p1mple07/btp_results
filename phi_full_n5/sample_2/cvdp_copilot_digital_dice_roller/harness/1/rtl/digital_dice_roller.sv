module digital_dice_roller(
    input clk,
    input reset_n,
    input button,
    output reg [2:0] dice_value
);

    // State encoding
    typedef enum'(i) state_t;
    typedef enum'(i) next_state_t;
    parameter IDLE = 3'b000, ROLLING = 3'b001;
    state_t current_state, next_state;

    // State register
    reg [2:0] state_reg;

    // Counter
    reg [2:0] counter = 3'b000;

    // State transition logic
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            current_state <= IDLE;
            dice_value <= 3'b000;
            state_reg <= IDLE;
            counter <= 3'b000;
        end else begin
            current_state <= state_reg;
            if (current_state == IDLE) begin
                if (button) begin
                    state_reg <= ROLLING;
                    counter <= 3'b000;
                end else begin
                    state_reg <= IDLE;
                    dice_value <= 3'b000;
                end
            end else if (current_state == ROLLING) begin
                if (counter < 3'b111) begin
                    counter <= counter + 3'b001;
                end else begin
                    dice_value <= counter;
                    state_reg <= IDLE;
                end
            end
        end
    end

endmodule
