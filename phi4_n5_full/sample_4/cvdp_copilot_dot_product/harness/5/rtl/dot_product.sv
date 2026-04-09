module dot_product (
    input               clk_in,
    input               reset_in,
    input               start_in,
    input       [7:0]   dot_length_in,
    input       [31:0]  vector_a_in,
    input               vector_a_valid_in,
    input       [31:0]  vector_b_in,
    input               vector_b_valid_in,
    input               a_complex_in,
    input               b_complex_in,
    output reg  [31:0]  dot_product_out,
    output reg          dot_product_valid_out,
    output reg          dot_product_error_out
);

    // State machine states: IDLE, COMPUTE, OUTPUT, ERROR
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10,
        ERROR   = 2'b11
    } state_t;

    state_t state;
    reg [7:0] cnt;
    reg [7:0] dot_length_reg;
    reg a_complex_reg;
    reg b_complex_reg;

    // Accumulators for real-only mode and complex modes
    reg [31:0] acc;      // For real-only mode
    reg [31:0] acc_re;   // For complex mode real part
    reg [31:0] acc_im;   // For complex mode imaginary part

    // Synchronous process
    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state            <= IDLE;
            cnt              <= 8'd0;
            dot_length_reg   <= 8'd0;
            a_complex_reg    <= 1'b0;
            b_complex_reg    <= 1'b0;
            acc              <= 32'd0;
            acc_re           <= 32'd0;
            acc_im           <= 32'd0;
            dot_product_out  <= 32'd0;
            dot_product_valid_out <= 1'b0;
            dot_product_error_out  <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    dot_product_valid_out <= 1'b0;
                    dot_product_error_out  <= 1'b0;
                    if (start_in) begin
                        state            <= COMPUTE;
                        cnt              <= 8'd0;
                        dot_length_reg   <= dot_length_in;
                        a_complex_reg    <= a_complex_in;
                        b_complex_reg    <= b_complex_in;
                        // Clear accumulators for all modes
                        acc              <= 32'd0;
                        acc_re           <= 32'd0;
                        acc_im           <= 32'd0;
                    end
                end

                COMPUTE: begin
                    // Error detection: if valid signals drop mid-computation, go to ERROR state
                    if (!vector_a_valid_in || !vector_b_valid_in) begin
                        state <= ERROR;
                    end
                    else begin
                        // Depending on the mode, perform the appropriate multiplication and accumulation.
                        if (!a_complex_reg && !b_complex_reg) begin
                            // Real-Only Mode: use lower 16 bits as the real value.
                            reg [15:0] a_val, b_val;
                            a_val = vector_a_in[15:0];
                            b_val = vector_b_in[15:0];
                            acc <= acc + (a_val * b_val);
                        end
                        else if (a_complex_reg && b_complex_reg) begin
                            // Complex-Only Mode: extract real and imaginary parts.
                            // Format: {Imaginary[31:16], Real[15:0]}
                            reg [15:0] A_re, A_im, B_re, B_im;
                            A_re = vector_a_in[15:0];
                            A_im = vector_a_in[31:16];
                            B_re = vector_b_in[15:0];
                            B_im = vector_b_in[31:16];
                            // Compute: Real = A_re*B_re - A_im*B_im, Imag = A_re*B_im + A_im*B_re
                            acc_re <= acc_re + (A_re * B_re - A_im * B_im);
                            acc_im <= acc_im + (A_re * B_im + A_im * B_re);
                        end
                        else begin
                            // Mixed Mode: one vector is complex and the other is real.
                            if (a_complex_reg && !b_complex_reg) begin
                                // A is complex, B is real.
                                reg [15:0] A_re, A_im, B_re;
                                A_re = vector_a_in[15:0];
                                A_im = vector_a_in[31:16];
                                B_re = vector_b_in[15:0];
                                acc_re <= acc_re + (A_re * B_re);
                                acc_im <= acc_im + (A_im * B_re);
                            end
                            else if (!a_complex_reg && b_complex_reg) begin
                                // A is real, B is complex.
                                reg [15:0] A_re, B_re, B_im;
                                A_re = vector_a_in[15:0];
                                B_re = vector_b_in[15:0];
                                B_im = vector_b_in[31:16];
                                // For a real vector, the imaginary component is 0.
                                acc_re <= acc_re + (A_re * B_re);
                                acc_im <= acc_im + (0 * B_re);
                            end
                        end

                        // Update counter and transition to OUTPUT when done.
                        if (cnt == dot_length_reg - 1)
                            state <= OUTPUT;
                        else
                            cnt <= cnt + 1;
                    end
                end

                OUTPUT: begin
                    // Format output based on the mode.
                    if (!a_complex_reg && !b_complex_reg) begin
                        // Real-Only Mode: output the accumulated result.
                        dot_product_out <= acc;
                    end
                    else begin
                        // Complex Modes: output concatenated {Imaginary[15:0], Real[15:0]}
                        dot_product_out <= {acc_im[15:0], acc_re[15:0]};
                    end
                    dot_product_valid_out <= 1'b1;
                    state <= IDLE;
                end

                ERROR: begin
                    // Error state: assert error output and hold until reset.
                    dot_product_error_out <= 1'b1;
                    dot_product_valid_out <= 1'b0;
                    dot_product_out      <= 32'd0;
                    // Remain in ERROR state until a reset occurs.
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule