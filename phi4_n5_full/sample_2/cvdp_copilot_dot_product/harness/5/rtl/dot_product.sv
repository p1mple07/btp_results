module dot_product (
    input               clk_in,                     // Clock signal
    input               reset_in,                   // Asynchronous Reset signal, Active HIGH
    input               start_in,                   // Start computation signal
    input       [7:0]   dot_length_in,              // Length of the dot product vectors (up to 256 elements)
    input       [31:0]  vector_a_in,                // Input vector A (32-bit)
    input               vector_a_valid_in,          // Valid signal for vector A
    input       [31:0]  vector_b_in,                // Input vector B (32-bit)
    input               vector_b_valid_in,          // Valid signal for vector B
    input               a_complex_in,               // Indicates if vector A is complex (1) or real (0)
    input               b_complex_in,               // Indicates if vector B is complex (1) or real (0)
    output reg  [31:0]  dot_product_out,            // Dot product result: real-only mode returns 32-bit real; complex mode returns {Imaginary[15:0], Real[15:0]}
    output reg          dot_product_valid_out,      // Valid signal for dot_product_out, active HIGH when computation is complete
    output reg          dot_product_error_out       // Error signal, active HIGH if valid signals drop mid-computation
);

    // State encoding: IDLE, COMPUTE, OUTPUT, ERROR
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10,
        ERROR   = 2'b11
    } state_t;

    state_t state;
    reg [31:0] acc_re;    // Accumulator for real part (used in real-only mode and as real part in complex modes)
    reg [31:0] acc_im;    // Accumulator for imaginary part (used in complex modes)
    reg [7:0]  cnt;       // Counter for processed elements
    reg [7:0]  dot_length_reg; // Registered vector length

    // Registers to hold extracted real/imaginary parts (updated every cycle)
    reg [15:0] A_re, A_im;
    reg [15:0] B_re, B_im;

    // Synchronous process for state machine and computation
    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state              <= IDLE;
            acc_re             <= 32'd0;
            acc_im             <= 32'd0;
            cnt                <= 8'd0;
            dot_length_reg     <= 8'd0;
            dot_product_out    <= 32'd0;
            dot_product_valid_out <= 1'b0;
            dot_product_error_out <= 1'b0;
            A_re               <= 16'd0;
            A_im               <= 16'd0;
            B_re               <= 16'd0;
            B_im               <= 16'd0;
        end else begin
            // Update extracted parts from vector inputs (for complex mode)
            A_re <= vector_a_in[15:0];
            A_im <= vector_a_in[31:16];
            B_re <= vector_b_in[15:0];
            B_im <= vector_b_in[31:16];

            case (state)
                IDLE: begin
                    dot_product_valid_out <= 1'b0;
                    dot_product_error_out <= 1'b0;
                    if (start_in) begin
                        // Check that valid signals are asserted at the start
                        if (vector_a_valid_in && vector_b_valid_in) begin
                            state             <= COMPUTE;
                            acc_re            <= 32'd0;
                            acc_im            <= 32'd0;
                            cnt               <= 8'd0;
                            dot_length_reg    <= dot_length_in;
                        end else begin
                            state             <= ERROR;
                        end
                    end
                end

                COMPUTE: begin
                    // Check for valid signals in each computation cycle
                    if (!vector_a_valid_in || !vector_b_valid_in) begin
                        state <= ERROR;
                    end else begin
                        // Determine mode and perform computation for one element
                        if (!a_complex_in && !b_complex_in) begin
                            // Real-Only Mode: Multiply full 32-bit values.
                            // Note: 32-bit multiplication produces a 64-bit result; we take the lower 32 bits.
                            acc_re <= acc_re + (vector_a_in * vector_b_in)[31:0];
                            // In real-only mode, imaginary part remains 0.
                            acc_im <= 32'd0;
                        end else if (a_complex_in && b_complex_in) begin
                            // Complex-Only Mode:
                            // Real part:  A_re * B_re - A_im * B_im
                            // Imaginary part: A_re * B_im + A_im * B_re
                            acc_re <= acc_re + (A_re * B_re - A_im * B_im);
                            acc_im <= acc_im + (A_re * B_im + A_im * B_re);
                        end else begin
                            // Mixed Mode: one vector is complex and the other is real.
                            if (a_complex_in && !b_complex_in) begin
                                // A is complex, B is real.
                                // Real: A_re * B; Imaginary: A_im * B.
                                // Multiplication: 16-bit * 32-bit yields a 48-bit result; take lower 32 bits.
                                acc_re <= acc_re + (A_re * vector_b_in)[31:0];
                                acc_im <= acc_im + (A_im * vector_b_in)[31:0];
                            end else if (!a_complex_in && b_complex_in) begin
                                // A is real, B is complex.
                                // Real: A * B_re; Imaginary: A * B_im.
                                acc_re <= acc_re + (vector_a_in * B_re)[31:0];
                                acc_im <= acc_im + (vector_a_in * B_im)[31:0];
                            end
                        end

                        cnt <= cnt + 1;
                        // If all elements have been processed, move to OUTPUT state.
                        if (cnt == dot_length_reg - 1)
                            state <= OUTPUT;
                        else
                            state <= COMPUTE;
                    end // valid signals check
                end

                OUTPUT: begin
                    // Format output based on mode.
                    if (!a_complex_in && !b_complex_in) begin
                        // Real-Only Mode: Output the accumulated real result.
                        dot_product_out <= acc_re;
                    end else begin
                        // Complex Modes: Concatenate {Imaginary[15:0], Real[15:0]}
                        dot_product_out <= {acc_im[15:0], acc_re[15:0]};
                    end
                    dot_product_valid_out <= 1'b1;
                    state <= IDLE;
                end

                ERROR: begin
                    // Error state: assert error signal and hold until reset.
                    dot_product_error_out <= 1'b1;
                    dot_product_out       <= 32'd0;
                    dot_product_valid_out <= 1'b0;
                    // Remain in ERROR state until asynchronous reset.
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule