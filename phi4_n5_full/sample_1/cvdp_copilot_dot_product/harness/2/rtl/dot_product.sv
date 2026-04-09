module dot_product (
    input               clk_in,                     // Clock signal
    input               reset_in,                   // Asynchronous Reset signal, Active HIGH
    input               start_in,                   // Start computation signal
    input       [6:0]   dot_length_in,              // Length of the dot product vectors
    // Assume maximum vector length is 128 elements
    input       [7:0]   vector_a_in   [0:127],      // Input vector A (8-bit)
    input               vector_a_valid_in [0:127],   // Valid signal for vector A elements
    input       [15:0]  vector_b_in    [0:127],      // Input vector B (16-bit)
    input               vector_b_valid_in [0:127],   // Valid signal for vector B elements
    output reg  [31:0]  dot_product_out,            // Output dot product result (32-bit)
    output reg          dot_product_valid_out       // Valid signal for dot product output
);

    // Parameter for maximum vector length
    parameter MAX_LEN = 128;

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10
    } state_t;

    state_t state;
    reg [6:0] index;             // Index for accessing vector elements
    reg [31:0] acc;              // Accumulator for dot product
    reg [1:0] output_latency_counter;  // Counter to implement 2-cycle output latency

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state             <= IDLE;
            index             <= 0;
            acc               <= 32'd0;
            dot_product_out   <= 32'd0;
            dot_product_valid_out <= 1'b0;
            output_latency_counter <= 2'd0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start_in) begin
                        state             <= COMPUTE;
                        index             <= 0;
                        acc               <= 32'd0;
                    end
                end

                COMPUTE: begin
                    if (index < dot_length_in) begin
                        // Multiply only if both corresponding valid signals are asserted;
                        // otherwise, treat the element as 0.
                        acc <= acc + ((vector_a_valid_in[index] ? vector_a_in[index] : 8'd0) *
                                      (vector_b_valid_in[index] ? vector_b_in[index] : 16'd0));
                        index <= index + 1;
                    end
                    else begin
                        state <= OUTPUT;
                    end
                end

                OUTPUT: begin
                    dot_product_out <= acc;
                    dot_product_valid_out <= 1'b1;
                    if (output_latency_counter < 2) begin
                        output_latency_counter <= output_latency_counter + 1;
                    end
                    else begin
                        state <= IDLE;
                        dot_product_valid_out <= 1'b0;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule