`timescale 1ns / 1ps

module digital_dice_roller #(
    parameter int DICE_MAX  = 6,
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,
    parameter int NUM_DICE = 2
) (
    input wire clk,
    input wire reset,
    input wire button,
    output reg [NUM_DICE * BIT_WIDTH - 1 : 0] dice_values
);

localparam num_dice = NUM_DICE;
localparam bit_width = $clog2(DICE_MAX) + 1;

reg [NUM_DICE - 1 : 0] state;
reg [BIT_WIDTH-1 : 0] seed;
reg [BIT_WIDTH-1 : 0] counter;

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        state <= {repeat(num_dice) {IDLE}};
        seed <= {repeat(num_dice) {1 << 4}}; // unique 16‑bit seeds
        counter <= {repeat(num_dice) {1’d0}};
    end else begin
        current_state = state;
        current_seed = seed;
        current_counter = counter;
    end
end

initial begin
    #5 reset = 1';
    #100000;
    assert(assert_equal(dice_values, 0x00000000));
end

always_comb begin
    next_state = current_state;
    case (current_state)
        IDLE: begin
            if (button) next_state = ROLLING;
        end
        ROLLING: begin
            if (!button) next_state = IDLE;
        end
    endcase
end

always_comb begin
    next_seed = current_seed ^ 1;
    case (current_state)
        IDLE: begin
            next_seed[0] = 0; // simple seed generation
        end
        ROLLING: begin
            next_seed[1] = next_seed[0];
        end
    endcase
end

always_comb begin
    next_counter = current_counter + 1;
    case (current_state)
        IDLE: begin
            next_counter = 1;
        end
        ROLLING: begin
            next_counter = 1;
        end
    endcase
end

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        dice_values <= 8'b0;
    end else begin
        if (current_state == ROLLING) begin
            dice_values <= {repeat(num_dice) {current_counter}};
        end else if (current_state == IDLE) begin
            dice_values <= {repeat(num_dice) {counter[0]}};
        end
    end
end

endmodule
