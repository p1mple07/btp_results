module digital_dice_roller(
    input clk,
    input reset_n,
    input button,
    output reg [2:0] dice_value
);

    // State encoding
    typedef enum'(int i) {
        IDLE,
        ROLLING
    } state_t;

    // State register
    state_t state, next_state;

    // Counter register
    reg [2:0] counter = 0;

    // State transition logic
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            state <= IDLE;
            dice_value <= 3'b000;
        end else begin
            state <= next_state;
        end
    end

    // State transition table
    always @* begin
        case (state)
            IDLE: begin
                if (button) begin
                    next_state = ROLLING;
                    dice_value <= 3'b000;
                end else begin
                    next_state = IDLE;
                end
            end
            ROLLING: begin
                if (button) begin
                    counter <= counter + 3'd1;
                    if (counter == 6'd6) begin
                        counter <= 3'd0;
                        next_state = IDLE;
                    end
                end else begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    // Output logic
    always @(state or counter) begin
        case ({state, counter})
            {IDLE, 3'd0}: dice_value <= 3'b000;
            {ROLLING, 3'd0}: dice_value <= 3'b000;
            {IDLE, 3'd1}: dice_value <= 3'b001;
            {IDLE, 3'd2}: dice_value <= 3'b010;
            {IDLE, 3'd3}: dice_value <= 3'b011;
            {IDLE, 3'd4}: dice_value <= 3'b100;
            {IDLE, 3'd5}: dice_value <= 3'b101;
            {IDLE, 3'd6}: dice_value <= 3'b110;
            {ROLLING, 3'd0}: dice_value <= 3'b110;
            {ROLLING, 3'd1}: dice_value <= 3'b111;
            default: dice_value <= 3'b000;
        endcase
    end

endmodule
