`timescale 1ns / 1ps

module digital_dice_roller #(
    parameter int DICE_MAX = 6,
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,
    parameter int NUM_DICE = 2
) (
    input wire clk,
    input wire reset,
    input wire button,
    output reg [BIT_WIDTH-1:0] dice_values
);

    localparam num_dice = NUM_DICE;
    localparam bitwidth = BIT_WIDTH;

    // Seed array for each die
    reg [15:0] seeds;
    initial assign seeds[0] = 1;
    initial assign seeds[1] = 2;
    initial assign seeds[2] = 3;
    for (int i = 3; i < num_dice; i++) begin : seed_loop
        seeds[i] = seeds[i-1] ^ (seeds[i-1] >> 1) ^ (seeds[i-1] >> 2) ^ (seeds[i-1] >> 4) ^ (seeds[i-1] >> 8) ^ (seeds[i-1] >> 13);
    end

    // Internal state: IDLE, ROLLING
    localparam state_t current_state, next_state;
    reg [1:0] current_state;

    // Counters
    reg [BIT_WIDTH-1:0] counter;
    reg [BIT_WIDTH-1:0] next_counter;

    // State machine
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            current_state <= IDLE;
            counter <= 1;
            dice_values <= 1;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (button) next_state = ROLLING;
                else next_state = IDLE;
            end

            ROLLING: begin
                if (!button) next_state = IDLE;
                else next_state = ROLLING;
            end
        endcase
    end

    // Combinational logic for rolling dice
    always_comb begin
        next_counter = 1;

        case (current_state)
            IDLE: begin
                dice_values <= counter;
            end

            ROLLING: begin
                if (!button) begin
                    for (int i = 0; i < num_dice; i++) begin
                        counter = next_counter ^ seeds[i];
                        next_counter = (counter >> 1) ^ (counter >> 2) ^ (counter >> 4) ^ (counter >> 8) ^ (counter >> 13);
                    end
                end else begin
                    // If rolling, we don't change state, but we still update? Maybe we can skip.
                end
            end
        endcase
    end

    // Output
    always_comb begin
        dice_values = { num_dice{counter} };
    end

endmodule
