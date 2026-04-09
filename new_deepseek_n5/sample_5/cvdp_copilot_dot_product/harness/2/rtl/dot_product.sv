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
    
    reg [31:0] accumulator = 0;
    
    always @ (posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state = IDLE;
            accumulator = 0;
        end else if (start_in) begin
            if (vector_a_valid_in & vector_b_valid_in) begin
                state = COMPUTE;
            end
        end
    end

    while (!state OUTPUT) begin
        if (state == COMPUTE) begin
            // Ensure vectors are properly sized
            if (vector_a_in[7:0] & vector_b_in[7:0]) begin
                accumulator = (vector_a_in[7:0] * vector_b_in[7:0]) + accumulator;
                state = state + 1;
            end
            // After processing all elements, transition to output state
            if (state == COMPUTE && vector_a_valid_in & vector_b_valid_in) begin
                state = OUTPUT;
                dot_product_valid_out = 1;
            end
        end
    end

    // After computation, wait two clock cycles for result to be valid
    delay #2;
    dot_product_out = accumulator;
endmodule