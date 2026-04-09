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
    reg [31:0] acc;

    // Initialize accumulator
    acc = 0;

    // State machine
    always_ff @(posedge clk_in or posedge reset_in) begin
        case (state)
            IDLE:
                if (start_in & 1) begin
                    if (dot_length_in != 0) begin
                        state = COMPUTE;
                    end
                end
                // else stay in IDLE
                acc = 0;
            COMPUTE:
                if (start_in & 1) begin
                    if (vector_a_valid_in & vector_b_valid_in) begin
                        // Multiply corresponding elements and accumulate
                        acc = acc + (vector_a_in[7:0] * vector_b_in[15:8]);
                        acc = (acc >> 1) + (acc << 29);
                    end
                end
                // After processing all elements, transition to OUTPUT state
                if (vector_a_valid_in & vector_b_valid_in) begin
                    state = OUTPUT;
                    dot_product_out = acc;
                    dot_product_valid_out = 1;
                end
            OUTPUT:
                // After 2 clock cycles, output remains valid
                dot_product_valid_out = 0;
        endcase
    end
endmodule