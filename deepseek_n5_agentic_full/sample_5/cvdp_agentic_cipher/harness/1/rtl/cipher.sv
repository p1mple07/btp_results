// State Machine Definition
enum state_t = {
    IDLE,
    ROUND,
    FINISH
};

// Module Implementation
module cipher(
    input wire clock,
    input wire rst_n,
    input wire start,
    input wire[31:0] data_in,
    input wire[15:0] key,
    output reg data_out,
    output reg done
) {

    // State Variables
    reg state_t state = IDLE;
    reg int16_t n_round = 0;
    reg[16:0] round_key;

    // Key Schedule Logic
    always_comb begin
        case(state)
            IDLE:
                // Initial Keying: Set initial state and capture key
                state = ROUND;
                n_round = 0;
                round_key = key;
                done = 0;
                data_out = 0;
                #1; // Wait for start signal
                state = IDLE;
                break;
            ROUND:
                // Generate next round key
                n_round <= n_round + 1;
                round_key <= ((round_key << 4) | (round_key >> 12)) ^ (n_round);
                done = 0;
                data_out = 0;
                #1;
                if (start) begin
                    // Enter processing phase
                    state = ROUND;
                end
                break;
            FINISH:
                // Finalize output
                state = IDLE;
                done <= 1;
                #1;
                break;
        default:
            state = IDLE;
    endcase

    // Feistel Function Implementation
    always_ff @(posedge clock) begin
        case(state)
            IDLE:
                // Initialization Phase
                state = ROUND;
                done = 0;
                data_out = 0;
                break;
            ROUND:
                // Feistel Transformation
                integer16_t left = (data_in[15:0]);
                integer16_t right = (data_in[31:16]);

                // Apply f_function
                integer16_t f_out = f_function(right, round_key);

                // XOR with left half
                integer16_t new_left = left ^ f_out;

                // Swap halves
                data_out = (new_left << 16) | right;
                right = new_left;

                // Update state
                state = ROUND;
                done = 0;
                #1;
                break;
            FINISH:
                // Finalization
                done <= 1;
                #1;
                state = IDLE;
                break;
        default:
            // Default case not implemented
        endcase
    endff
}