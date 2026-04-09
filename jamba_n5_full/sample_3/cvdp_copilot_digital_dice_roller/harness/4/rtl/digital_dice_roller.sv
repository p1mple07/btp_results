module digital_dice_roller #(
    parameter int DICE_MAX = 6,
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1
) (
    input wire clk,
    input wire reset,  // Asynchronous reset signal
    input wire button,
    output reg [NUM_DICE*BIT_WIDTH - 1:0] dice_values
);
