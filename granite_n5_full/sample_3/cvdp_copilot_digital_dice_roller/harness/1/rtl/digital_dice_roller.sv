module digital_dice_roller(
    input wire clk,
    input wire reset_n,
    input wire button,
    output reg [2:0] dice_value
);

reg [2:0] counter;

always @(posedge clk or posedge reset_n) begin
    if (!reset_n) begin
        counter <= 3'd0;
        dice_value <= 3'd0;
    end else begin
        if (button) begin
            counter <= counter + 1;
            if (counter == 3'd6) begin
                counter <= 3'd0;
            end
            dice_value <= counter;
        end else begin
            dice_value <= dice_value;
        end
    end
end

endmodule