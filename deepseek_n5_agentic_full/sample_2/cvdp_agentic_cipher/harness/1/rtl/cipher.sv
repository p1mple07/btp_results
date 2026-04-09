module
module cipher (
    parameter NUM_ROUNDS = 8,
    input wire [31:0] data_in,
    input wire key,
    input wire rst_n,
    input wire start,
    output wire data_out,
    output wire done
);

    // State declarations
    enum state_state_t state = IDLE; // Start in IDLE state

    // Key schedule parameters
    reg [15:0] round_key[NUM_ROUNDS]; // Array to hold round keys

    // Internal state variables
    reg [31:0] left, right; // Left and right halves of the data
    reg [31:0] temp; // Temporary variable for f_function computation

    // Initialization variables
    reg init_state = 1; // Initial state value
    reg round = 0; // Current round counter

    // Key schedule setup
    always @* begin
        // Initialize the round keys using key schedule algorithm
        for (int i = 0; i < NUM_ROUNDS; i++) {
            round_key[i] = shift_left(key, 4) ^ (i << 2);
        }
    end

    // Main encryption loop
    always @posedge clk begin
        case(state)
            IDLE: 
                // Wait until start is asserted
                if (!start) state = IDLE;
                
            ROUND: 
                // Capture inputs and prepare for encryption
                initial_state <= 0; // Transition to processing
                left <= data_in[31:16];
                right <= data_in[15:0];
                round <= 0;

                // Execute F-function
                f_function(right, temp, round_key[round], round);

                // XOR left and temp results
                temp ^= left;
                left <= right;
                right <= temp;

                // Increment round counter
                round <= round + 1;

                // If not last round, continue processing
                if (round != NUM_ROUNDS - 1) state = ROUND;
                else state = ROUND; // Stay in ROUND state until done

            FINISH: 
                // Assert done after successful encryption
                done <= 1;
                state = IDLE;
        endcase

        // Update state after positive edge
        state <= state + 1;
    end

    // F-function implementation
    procedure f_function(input reg [15:0] x, output reg temp, input reg k, input int idx);
        integer i;
        
        // Add round key with bitwise operations
        temp = x ^ k;
        
        // Perform bitwise operations (example: rotate left 4 bits)
        temp = shift_left(temp, 4) | shift_right(temp, (8 - 4));
        
        // Add more bitwise operations as per specification
        // Add round key again with different rotation
        temp ^= k ^ (idx << 2);
    endprocedure

endmodule