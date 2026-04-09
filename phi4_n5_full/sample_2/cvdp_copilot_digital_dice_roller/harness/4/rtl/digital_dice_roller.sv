module digital_dice_roller #(
    parameter int DICE_MAX  = 6,                    // Maximum dice value per dice
    parameter int NUM_DICE  = 2,                    // Number of dice to roll simultaneously
    parameter int BIT_WIDTH = $clog2(DICE_MAX) + 1  // Bit width to represent dice values [1, DICE_MAX]
) (
    input  wire                   clk,
    input  wire                   reset,  // Active LOW asynchronous reset
    input  wire                   button,
    output reg  [(NUM_DICE*BIT_WIDTH)-1:0] dice_values
);

  // State encoding
  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    ROLLING = 2'b01
  } state_t;

  state_t current_state, next_state;

  // Arrays for each dice: counter and 16-bit LFSR random seed
  logic [BIT_WIDTH-1:0] counter [0:NUM_DICE-1];
  logic [15:0]          random_seed [0:NUM_DICE-1];

  // Next state combinational logic
  always_comb begin
    next_state = current_state;
    case (current_state)
      IDLE:    if (button)
                 next_state = ROLLING;
      ROLLING: if (!button)
                 next_state = IDLE;
      default: next_state = current_state;
    endcase
  end

  // FSM, LFSR update, and counter update on positive clock edge or asynchronous reset
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset: set FSM to IDLE, initialize each dice counter to 1,
      // assign unique 16-bit seeds (e.g., dice1=1, dice2=2, etc.)
      current_state <= IDLE;
      for (int i = 0; i < NUM_DICE; i++) begin
         random_seed[i] <= i + 1;
         counter[i]     <= 1;
      end
      dice_values <= { {(NUM_DICE*BIT_WIDTH){1'b0}} };
    end else begin
      current_state <= next_state;
      if (current_state == ROLLING) begin
         // For each dice, update the 16-bit LFSR using polynomial: x^16 + x^5 + x^4 + x^3 + 1
         // Feedback bit is computed as: feedback = bit15 ^ bit4 ^ bit3 ^ bit2
         for (int i = 0; i < NUM_DICE; i++) begin
            bit feedback;
            feedback = random_seed[i][15] ^ random_seed[i][4] ^ random_seed[i][3] ^ random_seed[i][2];
            random_seed[i] <= { random_seed[i][14:0], feedback };
         end
         // Update each dice counter based on the random seed.
         // The dice value is computed as: (random_seed % DICE_MAX) + 1
         for (int i = 0; i < NUM_DICE; i++) begin
            counter[i] <= (random_seed[i] % DICE_MAX) + 1;
         end
      end else if (current_state == IDLE) begin
         // When transitioning to IDLE, latch the current counter values into the flattened output.
         // Each dice's value is stored in a BIT_WIDTH segment.
         for (int i = 0; i < NUM_DICE; i++) begin
            dice_values[(i+1)*BIT_WIDTH-1 -: BIT_WIDTH] = counter[i];
         end
      end
    end
  end

endmodule