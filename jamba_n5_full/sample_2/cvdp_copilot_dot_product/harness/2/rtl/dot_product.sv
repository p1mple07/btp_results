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
    reg [3:0] dot_prod;
    reg dot_valid;

    initial begin
        state <= IDLE;
    end

    always @(posedge clk_in) begin
        if (reset_in) begin
            state <= IDLE;
        end else begin
            state <= COMPUTE;
        end
    end

    always @(posedge clk_in) begin
        case (state)
            IDLE:
                if (start_in) begin
                    state <= COMPUTE;
                end
                // No further action
        endcase
    end

    always @(posedge clk_in) begin
        case (state)
            COMPUTE:
                if (dot_length_in > 0) begin
                    dot_prod = vector_a_in[dot_length_in-1] * vector_b_in[dot_length_in-1];
                    dot_prod += dot_prod;
                    dot_length_in = dot_length_in - 1;
                end
        endcase
    end

    always @(posedge clk_in) begin
        case (state)
            OUTPUT:
                dot_valid <= 1;
                dot_product_out = dot_prod;
        endcase
    end

endmodule
