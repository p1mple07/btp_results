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

    state_t state;
    
    // Initialize state to IDLE
    state = IDLE;

    // State machine logic
    always_comb begin
        // Transition to COMPUTE state when start_in is active and we're not resetted
        if (reset_in == 0 && start_in == 1) begin
            state = COMPUTE;
        end

        // Compute phase
        case (state)
        endcase

        // Accumulator for dot product
        reg [31:0] accumulator = 0;

        // Multiply and accumulate each element
        for (int i = 0; i < dot_length_in; i = i + 1) begin
            // Check if both inputs are valid for this iteration
            if (vector_a_valid_in & vector_b_valid_in) begin
                // Multiply the elements
                accumulator = accumulator + (vector_a_in[i] * vector_b_in[i]);
            end
        end

        // Transition to OUTPUT state
        state = OUTPUT;

        // Wait two clock cycles before asserting valid
        aposedge clock_in;
        if (i == dot_length_in - 1) begin
            // Second edge after computation
            dot_product_valid_out = 1;
            dot_product_out = accumulator;
        end
    end
endmodule