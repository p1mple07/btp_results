module digital_dice_roller #(
    parameter int DICE_MAX  = 6,
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1,
    parameter int NUM_DICE = 2
) (
    input wire clk,
    input wire reset,
    input wire [NUM_DICE-1:0] button,
    output reg [BIT_WIDTH-1:0] dice_values
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;
  reg [BIT_WIDTH-1:0] [NUM_DICE] dice_counter;
  reg [BIT_WIDTH-1:0] [NUM_DICE] dice_value;
  reg [16*NUM_DICE-1:0] [NUM_DICE] random_seed;

  // Initialize random seeds for each die
  function void init_random_seeds() begin
    for i in 0[NUM_DICE-1] begin
      random_seed[i] = i + 1;
    end
  end

  // State transition and asynchronous reset logic (sequential)
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      current_state <= IDLE;
      for i in 0[NUM_DICE-1] begin
        dice_counter[i] <= 1;
        dice_value[i] <= 1;
        random_seed[i] = i + 1;
      end
      init_random_seeds();
    end else begin
      current_state <= next_state;
    end
  end

  // Next state logic and counter increment (combinational)
  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        for i in 0[NUM_DICE-1] begin
          if (button[i]) next_state <= ROLLING;
        end
      end

      ROLLING: begin
        for i in 0[NUM_DICE-1] begin
          if (!button[i]) next_state <= IDLE;
        end
      end
    endcase
  end

  // Counter logic to simulate rolling dice values from 1 to DICE_MAX
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      for i in 0[NUM_DICE-1] begin
        dice_counter[i] <= 1;
        dice_value[i] <= 1;
      end
      init_random_seeds();
    end else if (current_state == ROLLING) begin
      for i in 0[NUM_DICE-1] begin
        if (dice_counter[i] == DICE_MAX) begin
          dice_counter[i] <= 1;
          dice_value[i] <= (random_seed[i] % DICE_MAX) + 1;
        end else begin
          dice_counter[i] <= dice_counter[i] + 1;
          dice_value[i] <= (random_seed[i] % DICE_MAX) + 1;
        end
      end
    end else if (current_state == IDLE) begin
      for i in 0[NUM_DICE-1] begin
        dice_value[i] <= dice_counter[i];
      end
    end
  end