module dot_product (
    input         clk_in,                     // Clock signal
    input         reset_in,                   // Asynchronous reset signal, active HIGH
    input         start_in,                   // Start computation signal, Active HIGH for one clock cycle
    input         [6:0]      dot_length_in,   // Length of the dot product vectors
    input         [7:0]      vector_a_in,      // Input vector A (8-bit)
    input         vector_a_valid_in,          // Valid signal for vector A, active HIGH
    input         [15:0]     vector_b_in,      // Input vector B (16-bit)
    input         vector_b_valid_in,          // Valid signal for vector B, active HIGH
    output reg  [31:0]     dot_product_out,  // Output dot product result (32-bit)
    output reg     dot_product_valid_out,    // Valid signal for dot product output
    output reg     dot_product_error_out      // Error signal, active HIGH if valid signals drop mid-computation
);

    logic      mode;
    logic      a_complex_in;
    logic      b_complex_in;

    assign mode = a_complex_in;
    assign mode = b_complex_in;
    // Alternatively, we could have separate a_complex_in and b_complex_in. But the spec says we need to support mixed.

    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state <= IDLE;
            dot_product_valid_out <= 0;
            dot_product_error_out <= 1;
            dot_product_out <= 32'd0;
        end else begin
            case (mode)
                IDLE: begin
                    dot_product_valid_out <= 0;
                    dot_length_reg <= dot_length_in;
                    if (start_in) begin
                        state <= COMPUTE;
                        acc <= 0;
                        cnt <= 0;
                    end
                end
                COMPUTE: begin
                    if (vector_a_valid_in && vector_b_valid_in) begin
                        acc <= acc + (vector_a_in * vector_b_in);
                        cnt <= cnt + 1;
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
                default: state <= IDLE;
            endcase
        end
    end

endmodule
