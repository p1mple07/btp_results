module dot_product (
    input               clk_in,                     // Clock signal
    input               reset_in,                   // Asynchronous Reset signal, Active HIGH
    input               start_in,                   // Start computation signal
    input       [7:0]   dot_length_in,              // Length of the dot product vectors
    input       [31:0]   vector_a_in,                // Input vector A (32-bit)
    input               vector_a_valid_in,          // Valid signal for vector A
    input       [31:0]   vector_b_in,                // Input vector B (32-bit)
    input               vector_b_valid_in,          // Valid signal for vector B
    input               a_complex_in,               // Indicates if vector A is complex
    input               b_complex_in,               // Indicates if vector B is complex
    output reg  [31:0]  dot_product_out,            // Output dot product result (32-bit)
    output reg          dot_product_valid_out       // Valid signal for dot product output
);

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10,
        COMPLEX = 2'b11
    } state_t;

    state_t state;
    reg [31:0] acc_re, acc_im; // Accumulators for real and imaginary parts
    reg [6:0] cnt;
    reg vector_a_valid_in_prev;
    reg vector_b_valid_in_prev;

    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state <= IDLE;
            acc_re <= 0;
            acc_im <= 0;
            cnt <= 0;
            dot_product_out <= 0;
            dot_product_valid_out <= 0;
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
                        if (a_complex_in && b_complex_in) begin
                            // Complex multiplication
                            acc_re <= acc_re + (vector_a_in[15:0] & vector_b_in[15:0]);
                            acc_im <= acc_im + (vector_a_in[15:0] ^ vector_b_in[15:0]);
                        elsif (a_complex_in) begin
                            // Mixed mode (A complex, B real)
                            acc_re <= acc_re + vector_a_in[15:0] & vector_b_in[15:0];
                        elsif (b_complex_in) begin
                            // Mixed mode (A real, B complex)
                            acc_im <= acc_im + vector_a_in[15:0] & vector_b_in[15:0];
                        end else begin
                            // Real multiplication
                            acc_re <= acc_re + vector_a_in & vector_b_in;
                        end
                        cnt <= cnt + 1;
                    end
                    if (cnt == dot_length_reg - 1) begin
                        state <= OUTPUT;
                    end else begin
                        state <= COMPUTE;
                    end
                end
                OUTPUT: begin
                    dot_product_out <= (acc_im << 17) | acc_re;
                    dot_product_valid_out <= 1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    // Error handling
    if (vector_a_valid_in != vector_a_valid_in_prev || vector_b_valid_in != vector_b_valid_in_prev) begin
        dot_product_error_out <= 1;
        acc_re <= 0;
        acc_im <= 0;
        cnt <= 0;
        dot_product_valid_out <= 0;
    end
endmodule