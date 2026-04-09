//digital_dice_roller.sv
module digital_dice_roller #(parameter NUM_DICE = 2, PARAMETER DICE_MAX = 6) (
    input logic clk,
    input logic reset,
    input logic button,
    output logic [7:0] dice_values
);
    
    localparam NUM_DICE = 2;
    localparam DICE_MAX = 6;
    logic [7:0] dice_values;
    
    always_ff @(posedge clk or negedge reset) begin
        if (reset) begin
            // Initialize dice counters to 1 at reset
            // (Assuming no other code in the project)
            for (int i = 0:NUM_DICE-1) begin
                assign dice_values[i] = 8'd0;
            end
        end
    endgenerate