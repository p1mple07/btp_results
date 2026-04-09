module dot_product (
    input               clk_in,                     // Clock signal
    input               reset_in,                   // Asynchronous Reset signal, Active HIGH
    input               start_in,                   // Start computation signal
    input               a_complex_in,               // Input signal indicating if vector A is complex
    input               b_complex_in,               // Input signal indicating if vector B is complex
    input               [31:0]   dot_length_in,              // Length of the dot product vectors
    input               [31:0]   vector_a_in,                // Input vector A (32-bit)
    input               vector_a_valid_in,          // Valid signal for vector A
    input               [31:0]  vector_b_in,                // Input vector B (32-bit)
    input               vector_b_valid_in,          // Valid signal for vector B
    output reg [31:0]  dot_product_out,            // Output dot product result (32-bit)
    output reg          dot_product_valid_out,      // Valid signal for dot product output
    output reg          dot_product_error_out       // Error signal, active HIGH if valid signals drop mid-computation
);

    typedef enum logic [1:0] {
        IDLE,
        COMPUTE,
        OUTPUT,
        ERROR
    } state_t;

    reg [31:0] acc_re; // Real part accumulator
    reg [31:0] acc_im; // Imaginary part accumulator
    reg [31:0] acc;    // Total accumulator
    reg [31:0] cnt;    // Counter for dot_length_reg
    reg [31:0] dot_length_reg;
    reg vector_a_valid_in_prev;
    reg vector_b_valid_in_prev;

    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state <= IDLE;
            acc_re <= 0;
            acc_im <= 0;
            acc <= 0;
            dot_product_valid_out <= 0;
            dot_product_error_out <= 0;
            dot_length_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    dot_product_valid_out <= 0;
                    dot_length_reg <= dot_length_in;
                    if (start_in) begin
                        state <= COMPUTE;
                        acc_re <= 0;
                        acc_im <= 0;
                    end
                end
                COMPUTE: begin
                    if (vector_a_valid_in && vector_b_valid_in) begin
                        if (a_complex_in) begin
                            acc_re <= acc_re + (vector_a_in[15:0] * vector_b_in[15:0]);
                            acc_im <= acc_im + (vector_a_in[31:16] * vector_b_in[31:16]);
                        end else begin
                            acc_re <= acc_re + (vector_a_in[15:0] * vector_b_in[15:0]);
                            acc_im <= acc_im - (vector_a_in[31:16] * vector_b_in[31:16]);
                        end
                        cnt <= cnt + 1;
                    end else begin
                        dot_product_error_out <= 1;
                        state <= ERROR;
                    end
                    if (cnt == dot_length_reg - 1) begin
                        state <= OUTPUT;
                    end else begin
                        state <= COMPUTE;
                    end
                end
                OUTPUT: begin
                    dot_product_out <= acc;
                    dot_product_valid_out <= 1;
                    state <= IDLE;
                end
                ERROR: begin
                    dot_product_out <= 32'h00000000;
                    dot_product_valid_out <= 0;
                    dot_product_error_out <= 1;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
