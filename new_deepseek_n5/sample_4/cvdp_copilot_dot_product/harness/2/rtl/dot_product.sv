module dot_product (
    input               clk_in,                     // Clock signal
    input               reset_in,                   // Asynchronous Reset signal, Active HIGH
    input               start_in,                   // Start computation signal
    input       [6:0]   dot_length_in,              // Length of the dot product vectors
    input       [7:0]   vector_a_in,                // Input vector A (8-bit)
    input               vector_a_valid_in,          // Valid signal for vector A
    input       [15:0]  vector_b_in,                // Input vector B (16-bit)
    input               vector_b_valid_in,          // Valid signal for vector B
    output reg  [31:0]  dot_product_out,            // Output dot product result (32-bit)
    output reg          dot_product_valid_out       // Valid signal for dot product output
);

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10
    } state_t;

    wire state;
    reg [31:0] accumulator;

    // Initialize state to IDLE
    state = IDLE;

    // Compute state
    always @poseditl(input)
    state = case { 
        .start_in & ~reset_in ? COMPUTE : IDLE 
    };

    // Accumulate products in compute state
    always @poseditl(input, state)
    state = case {
        .IDLE : output state is IDLE,
        .COMPUTE : 
            for (int i = 0; i < dot_length_in; i++) {
                if (vector_a_valid_in & vector_b_valid_in) {
                    accumulator = accumulator + (vector_a_in[i] * vector_b_in[i]);
                }
                // Update valid_out to indicate processing is ongoing
                dot_product_valid_out = 1;
            }
            // Transition to output state
            state = OUTPUT;
            // Set valid_out to 1 (result is being computed)
            dot_product_valid_out = 1;
            // After one clock cycle, valid_out will be set to 0
            posedge #1;
            dot_product_valid_out = 0;
        .OUTPUT : 
            // Output the accumulated result
            dot_product_out = accumulator;
            // Set valid_out to 1 (result is valid)
            dot_product_valid_out = 1;
            // After two clock cycles, valid_out will be set to 0
            posedge #1;
            dot_product_valid_out = 0;
            posedge #1;
            dot_product_valid_out = 0;
    };

    // Output the final result
    dot_product_out = accumulator;
    dot_product_valid_out = 1;
    posedge #2;
    dot_product_valid_out = 0;
endmodule