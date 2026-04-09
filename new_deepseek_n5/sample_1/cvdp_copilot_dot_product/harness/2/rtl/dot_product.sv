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

    initial begin
        state = IDLE;
    end

    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state = IDLE;
            accumulator = 0;
        end else if (start_in) begin
            if (state == IDLE) begin
                state = COMPUTE;
            end else if (state == COMPUTE) begin
                if (vector_a_valid_in & vector_b_valid_in) begin
                    // Multiply and accumulate
                    accumulator = [31:0] (accumulator + (vector_a_in[0:7] * vector_b_in[0:15]));
                    // Check for overflow
                    if (overflow32 #16(accumulator)) begin
                        dot_product_valid_out = 0;
                    end else begin
                        dot_product_valid_out = 0;
                    end
                end else begin
                    // Invalid input, wait for valid signals
                    state = COMPUTE;
                end
            end
        end else if (state == COMPUTE && dot_length_in > 0) begin
            for (int i = 0; i < dot_length_in; i++) {
                if (vector_a_valid_in & vector_b_valid_in) begin
                    // Multiply and accumulate
                    accumulator = [31:0] (accumulator + (vector_a_in[0:7] * vector_b_in[0:15]));
                    // Check for overflow
                    if (overflow32 #16(accumulator)) begin
                        dot_product_valid_out = 0;
                    end else begin
                        dot_product_valid_out = 0;
                    end
                end else begin
                    // Invalid input, wait for valid signals
                    state = COMPUTE;
                end
            end
            state = OUTPUT;
            dot_product_valid_out = 1;
        end
    end
end