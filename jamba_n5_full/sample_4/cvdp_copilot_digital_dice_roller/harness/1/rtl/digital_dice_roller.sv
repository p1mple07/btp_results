module digital_dice_roller (
    input wire clk,
    input wire reset_n,
    input wire button,
    output reg [2:0] dice_value
);

reg [2:0] state;
reg [2:0] counter;

always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
        state <= IDLE;
        counter <= 3'd0;
    end else begin
        if (state == IDLE) begin
            if (button) begin
                state <= ROLLING;
                counter <= 3'd1;
            end
        end else begin
            if (!button) begin
                state <= IDLE;
                counter <= 3'd0;
            end
            counter <= counter + 1;
        end
    end
end

always @(*) begin
    case (state)
        IDLE: dice_value = 3'b000;
        ROLLING: dice_value = counter;
    endcase
end

endmodule
