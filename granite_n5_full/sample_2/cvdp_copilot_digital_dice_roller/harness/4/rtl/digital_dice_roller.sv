module digital_dice_roller (
    parameter int NUM_DICE = 2,
    parameter int DICE_MAX = 6,
    
    input clk,
    input rst,
    input btn,
    
    output logic signed [31:0] dice_values
);

//...

endmodule