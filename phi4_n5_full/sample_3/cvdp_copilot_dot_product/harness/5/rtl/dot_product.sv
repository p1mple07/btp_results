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

    // State definition
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10,
        ERROR   = 2'b11
    } state_t;

    state_t state;

    // Registered inputs for robust handling
    reg [31:0] vector_a_in_reg;
    reg [31:0] vector_b_in_reg;
    reg        vector_a_valid_in_reg;
    reg        vector_b_valid_in_reg;
    reg        a_complex_in_reg;
    reg        b_complex_in_reg;
    reg [7:0]  dot_length_reg;

    // Accumulators and counters
    reg [31:0] acc;       // For real-only mode
    reg [31:0] acc_re;    // For real part in complex/mixed mode
    reg [31:0] acc_im;    // For imaginary part in complex/mixed mode
    reg [7:0]  cnt;       // Counter for processed elements
    reg [1:0]  latency_counter; // For 3-cycle output latency

    // Mode detection (using registered inputs)
    wire is_real_mode   = (~a_complex_in_reg) & (~b_complex_in_reg);
    wire is_complex_mode = a_complex_in_reg & b_complex_in_reg;
    wire is_mixed_mode  = a_complex_in_reg ^ b_complex_in_reg; // XOR

    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state <= IDLE;
            vector_a_in_reg        <= 32'h0;
            vector_b_in_reg        <= 32'h0;
            vector_a_valid_in_reg  <= 1'b0;
            vector_b_valid_in_reg  <= 1'b0;
            a_complex_in_reg       <= 1'b0;
            b_complex_in_reg       <= 1'b0;
            dot_length_reg         <= 8'h0;
            acc                    <= 32'h0;
            acc_re                 <= 32'h0;
            acc_im                 <= 32'h0;
            cnt                    <= 8'h0;
            latency_counter        <= 2'b0;
            dot_product_out        <= 32'h0;
            dot_product_valid_out  <= 1'b0;
            dot_product_error_out  <= 1'b0;
        end else begin
            // Register inputs
            vector_a_in_reg        <= vector_a_in;
            vector_b_in_reg        <= vector_b_in;
            vector_a_valid_in_reg  <= vector_a_valid_in;
            vector_b_valid_in_reg  <= vector_b_valid_in;
            a_complex_in_reg       <= a_complex_in;
            b_complex_in_reg       <= b_complex_in;
            dot_length_reg         <= dot_length_in;

            case (state)
                IDLE: begin
                    dot_product_valid_out <= 1'b0;
                    dot_product_error_out <= 1'b0;
                    // Initialize accumulators based on mode
                    if (is_real_mode) begin
                        acc <= 32'h0;
                        cnt <= 8'h0;
                    end else if (is_complex_mode || is_mixed_mode) begin
                        acc_re <= 32'h0;
                        acc_im <= 32'h0;
                        cnt <= 8'h0;
                    end
                    if (start_in) begin
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    // Error detection: if valid signals drop mid-computation
                    if (~vector_a_valid_in_reg || ~vector_b_valid_in_reg) begin
                        dot_product_error_out <= 1'b1;
                        state <= ERROR;
                    end else begin
                        // Perform computation based on mode
                        if (is_real_mode) begin
                            // For real-only mode, use lower 16 bits of each input
                            if (vector_a_valid_in_reg && vector_b_valid_in_reg) begin
                                acc <= acc + (vector_a_in_reg[15:0] * vector_b_in_reg[15:0]);
                                cnt <= cnt + 1;
                            end
                        end else if (is_complex_mode) begin
                            // For complex-only mode:
                            // A: real = lower 16 bits, imag = upper 16 bits; B similarly
                            acc_re <= acc_re + ((vector_a_in_reg[15:0] * vector_b_in_reg[15:0]) 
                                                - (vector_a_in_reg[31:16] * vector_b_in_reg[31:16]));
                            acc_im <= acc_im + ((vector_a_in_reg[15:0] * vector_b_in_reg[31:16]) 
                                                + (vector_a_in_reg[31:16] * vector_b_in_reg[15:0]));
                            cnt <= cnt + 1;
                        end else if (is_mixed_mode) begin
                            if (a_complex_in_reg && ~b_complex_in_reg) begin
                                // Mixed mode: A is complex, B is real.
                                acc_re <= acc_re + (vector_a_in_reg[15:0] * vector_b_in_reg[15:0]);
                                acc_im <= acc_im + (vector_a_in_reg[31:16] * vector_b_in_reg[15:0]);
                                cnt <= cnt + 1;
                            end else if (~a_complex_in_reg && b_complex_in_reg) begin
                                // Mixed mode: A is real, B is complex.
                                acc_re <= acc_re + (vector_a_in_reg[15:0] * vector_b_in_reg[15:0]);
                                acc_im <= acc_im + (vector_a_in_reg[15:0] * vector_b_in_reg[31:16]);
                                cnt <= cnt + 1;
                            end
                        end

                        // Transition to OUTPUT state when all elements are processed
                        if (cnt == dot_length_reg - 1) begin
                            state <= OUTPUT;
                        end else begin
                            state <= COMPUTE;
                        end
                    end
                end

                OUTPUT: begin
                    // Implement 3-cycle output latency
                    if (latency_counter < 2'd3) begin
                        latency_counter <= latency_counter + 1;
                        dot_product_valid_out <= 1'b0;
                    end else begin
                        // Latch the computed result based on mode
                        if (is_real_mode) begin
                            dot_product_out <= acc;
                        end else if (is_complex_mode || is_mixed_mode) begin
                            // Concatenate {Imaginary[15:0], Real[15:0]}
                            dot_product_out <= {acc_im[15:0], acc_re[15:0]};
                        end
                        dot_product_valid_out <= 1'b1;
                        state <= IDLE;
                    end
                end

                ERROR: begin
                    dot_product_error_out <= 1'b1;
                    dot_product_valid_out <= 1'b0;
                    dot_product_out <= 32'h00000000;
                    // Optionally reset computation after error detection
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule