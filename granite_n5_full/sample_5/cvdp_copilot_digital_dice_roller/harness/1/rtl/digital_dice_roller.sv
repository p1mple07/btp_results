module digital_dice_roller (
    input wire clk,
    input wire reset_n,
    input wire button,
    output reg [2:0] dice_value
);

reg [2:0] counter;
reg [2:0] next_counter;

always @(posedge clk or posedge reset_n) begin
    if (!reset_n) begin
        counter <= 3'b0;
    end else begin
        counter <= next_counter;
    end
end

always @(*) begin
    case (counter)
        3'b000: next_counter = 3'b001;
        3'b001: next_counter = 3'b010;
        3'b010: next_counter = 3'b011;
        3'b011: next_counter = 3'b100;
        3'b100: next_counter = 3'b101;
        3'b101: next_counter = 3'b110;
        3'b110: next_counter = 3'b111;
        3'b111: next_counter = 3'b000;
        default: next_counter = 3'b000; // Default case
    endcase
end

always @(*) begin
    if (button && ~button_prev) begin
        dice_value <= counter;
    end else if (~button && button_prev) begin
        dice_value <= 3'b000;
    end
    button_prev <= button;
end

endmodule