module digital_dice_roller #(
    parameter int DICE_MAX  = 6,
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,
    parameter int NUM_DICE = 2
) (
    input wire clk,
    input wire reset,  // Active LOW
    input wire button,
    output reg [NUM_DICE * BIT_WIDTH - 1 : 0] dice_values
);

// Internal signals
logic [NUM_DICE-1:0] seed;
reg [BIT_WIDTH-1:0] counter[NUM_DICE];
logic current_state, next_state;

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        current_state <= IDLE;
        counter[0] <= 1;  // Initialize first dice to 1
        counter[1] <= 1;  // Or maybe we need to initialize all? But only two examples.
        seed[0] <= 1;
        seed[1] <= 2;
        for (int i = 2; i < NUM_DICE; i++) counter[i] <= 1;
        seed[NUM_DICE-1] <= 3;
        dice_values <= 0;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    next_state = current_state;

    case (current_state)
        IDLE: begin
            if (button) begin
                next_state = ROLLING;
            end
        end

        ROLLING: begin
            if (!button) begin
                next_state = IDLE;
            end
        end
    endcase
end

// Roll the dice
always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        // Reset all counters and seed
        for (int i = 0; i < NUM_DICE; i++)
            counter[i] <= 1;
        seed[0] <= 1;
        seed[1] <= 2;
        // ... etc.
    end else begin
        if (current_state == ROLLING) begin
            for (int i = 0; i < NUM_DICE; i++)
                counter[i] <= counter[i] + 1;
        end
    end
end

// Update dice values
always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        for (int i = 0; i < NUM_DICE; i++)
            dice_values[i * BIT_WIDTH + (BIT_WIDTH-1)] = counter[i];
    end else begin
        if (current_state == IDLE) begin
            for (int i = 0; i < NUM_DICE; i++)
                dice_values[i * BIT_WIDTH + (BIT_WIDTH-1)] = counter[i];
        end
    end
end

endmodule
