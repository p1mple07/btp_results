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
    reg    sum;

    always @(posedge clk_in) begin
        case (state)
            IDLE: begin
                if (start_in) begin
                    state <= COMPUTE;
                end else begin
                    state <= IDLE;
                end
            end

            COMPUTE: begin
                if (dot_length_in > 0) begin
                    sum = 0;
                    for (int i = 0; i < dot_length_in; i++) begin
                        sum += vector_a_in[i] * vector_b_in[i];
                    end
                end
                state <= OUTPUT;
            end

            OUTPUT: begin
                dot_product_out = sum;
                dot_product_valid_out = 1;
            end
        endcase
    end

    always @(*) begin
        if (reset_in) begin
            state <= IDLE;
            dot_product_out = 32'h00000000;
            dot_product_valid_out = 0;
        end
    end

endmodule
