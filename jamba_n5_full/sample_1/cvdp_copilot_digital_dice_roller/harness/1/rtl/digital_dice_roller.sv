module digital_dice_roller (
    input clk,
    input reset_n,
    input button,
    output reg [2:0] dice_value,
    output reg [2:0] counter,
    output reg roll_started
);

initial begin
    dice_value = 0;
    counter = 0;
    roll_started = 0;
end

always @(posedge clk) begin
    if (!reset_n) return;

    if (button) begin
        if (roll_started) begin
            if (button) begin
                // Keep rolling
                counter <= counter + 1;
                if (counter == 6) counter <= 1;
            end else begin
                // End the rolling and record the last value
                dice_value = counter;
                roll_started = 0;
                return_to_idle = 1;
            end
        end else begin
            // Start rolling on the first button press
            dice_value = 1;
            roll_started = 1;
        end
    end
end

always @(*) begin
    if (return_to_idle) begin
        dice_value = 0;
    end
end

endmodule
