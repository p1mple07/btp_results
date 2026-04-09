module digital_dice_roller (
    input wire clk,
    input wire reset_n,
    input wire button,
    output reg [2:0] dice_value,
    output reg [2:0] last_value
);

reg [1:0] state;
reg counter;

initial begin
    state = IDLE;
    dice_value = 3'd0;
    last_value = 3'd0;
    counter = 0;
end

always @(posedge clk) begin
    if (reset_n) begin
        state <= IDLE;
        dice_value = 3'd0;
        last_value = 3'd0;
        counter = 0;
    end else begin
        case (state)
            IDLE: begin
                if (button == 1) begin
                    state = ROLLING;
                    last_value = 3'd0;
                end
            end
            ROLLING: begin
                if (button == 1) begin
                    if (counter < 6) begin
                        counter <= counter + 1;
                    end else begin
                        counter = 1;
                    end
                end
            end
            default: pass;
        endcase
    end
end

always @(*) begin
    dice_value = counter;
end

endmodule
