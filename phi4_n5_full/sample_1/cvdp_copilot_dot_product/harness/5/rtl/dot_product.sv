module dot_product (
    input               clk_in,                     // Clock signal
    input               reset_in,                   // Asynchronous Reset signal, Active HIGH
    input               start_in,                   // Start computation signal
    input       [7:0]   dot_length_in,              // Length of the dot product vectors (up to 256 elements)
    input       [31:0]  vector_a_in,                // Input vector A: {Imaginary[31:16], Real[15:0]}
    input               vector_a_valid_in,          // Valid signal for vector A
    input       [31:0]  vector_b_in,                // Input vector B: {Imaginary[31:16], Real[15:0]}
    input               vector_b_valid_in,          // Valid signal for vector B
    input               a_complex_in,               // 1 = vector A is complex, 0 = real
    input               b_complex_in,               // 1 = vector B is complex, 0 = real
    output reg  [31:0]  dot_product_out,            // Dot product result: real-only (32-bit) or complex ({Imag[15:0], Real[15:0]})
    output reg          dot_product_valid_out,      // High when output is valid
    output reg          dot_product_error_out       // High if an error (e.g. dropped valid signal) is detected
);

    // State machine states: IDLE, COMPUTE, OUTPUT, ERROR
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10,
        ERROR   = 2'b11
    } state_t;

    state_t state;

    // Internal registers for registered inputs
    reg [31:0] vector_a_in_reg;
    reg [31:0] vector_b_in_reg;
    reg [7:0]  dot_length_reg;
    reg        a_complex_reg;
    reg        b_complex_reg;
    reg        vector_a_valid_reg;
    reg        vector_b_valid_reg;

    // Accumulators for real-only mode (32-bit) and complex mode (16-bit each)
    reg [31:0] acc;       // Used in real-only mode
    reg [15:0] acc_re;    // Real accumulator for complex modes
    reg [15:0] acc_im;    // Imaginary accumulator for complex modes

    // Counter for number of processed elements
    reg [7:0] cnt;

    // Synchronous process: state machine and computation
    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state              <= IDLE;
            vector_a_in_reg    <= 32'd0;
            vector_b_in_reg    <= 32'd0;
            dot_length_reg     <= 8'd0;
            a_complex_reg      <= 1'b0;
            b_complex_reg      <= 1'b0;
            vector_a_valid_reg <= 1'b0;
            vector_b_valid_reg <= 1'b0;
            acc                <= 32'd0;
            acc_re             <= 16'd0;
            acc_im             <= 16'd0;
            cnt                <= 8'd0;
            dot_product_out    <= 32'd0;
            dot_product_valid_out <= 1'b0;
            dot_product_error_out <= 1'b0;
        end else begin
            // Register all inputs every cycle
            vector_a_in_reg    <= vector_a_in;
            vector_b_in_reg    <= vector_b_in;
            dot_length_reg     <= dot_length_in;
            a_complex_reg      <= a_complex_in;
            b_complex_reg      <= b_complex_in;
            vector_a_valid_reg <= vector_a_valid_in;
            vector_b_valid_reg <= vector_b_valid_in;

            case (state)
                IDLE: begin
                    dot_product_valid_out <= 1'b0;
                    dot_product_error_out <= 1'b0;
                    // Wait for start signal and valid inputs to begin computation
                    if (start_in && vector_a_valid_in && vector_b_valid_in) begin
                        // Initialize accumulators based on mode
                        if (!a_complex_in && !b_complex_in) begin
                            // Real-Only Mode: use 32-bit accumulator
                            acc    <= 32'd0;
                            cnt    <= 8'd0;
                        end else begin
                            // Complex mode (Complex-Only or Mixed): use 16-bit accumulators
                            acc_re <= 16'd0;
                            acc_im <= 16'd0;
                            cnt    <= 8'd0;
                        end
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    // Error detection: if either valid signal drops mid-computation, go to ERROR state
                    if (!vector_a_valid_reg || !vector_b_valid_reg) begin
                        state              <= ERROR;
                        dot_product_error_out <= 1'b1;
                    end else begin
                        // Determine operation mode based on registered mode flags
                        if (!a_complex_reg && !b_complex_reg) begin
                            // Real-Only Mode: use lower 16 bits as the real value
                            // Multiply and accumulate: product = A_real * B_real
                            acc <= acc + (vector_a_in_reg[15:0] * vector_b_in_reg[15:0]);
                        end else begin
                            // Complex Mode (either Complex-Only or Mixed)
                            // Extract real and imaginary parts from inputs
                            // A: {Imag[31:16], Real[15:0]}
                            // B: {Imag[31:16], Real[15:0]}
                            // For multiplication, zero-extend 16-bit values to 32 bits.
                            // Define intermediate signals for clarity:
                            // (Note: These signals are local to this procedural block.)
                            // Real part of A and B:
                            wire [15:0] A_re = vector_a_in_reg[15:0];
                            wire [15:0] B_re = vector_b_in_reg[15:0];
                            // Imaginary part of A and B:
                            wire [15:0] A_im = vector_a_in_reg[31:16];
                            wire [15:0] B_im = vector_b_in_reg[31:16];
                            
                            if (a_complex_reg && b_complex_reg) begin
                                // Complex-Only Mode:
                                // Real part: A_re*B_re - A_im*B_im
                                // Imaginary part: A_re*B_im + A_im*B_re
                                // Multiply using zero-extension and then truncate to 16 bits.
                                acc_re <= acc_re + 
                                          (( {1'b0, A_re} * {1'b0, B_re} -
                                             {1'b0, A_im} * {1'b0, B_im} ) [15:0]);
                                acc_im <= acc_im + 
                                          (( {1'b0, A_re} * {1'b0, B_im} +
                                             {1'b0, A_im} * {1'b0, B_re} ) [15:0]);
                            end else begin
                                // Mixed Mode: one vector is complex and the other is real.
                                if (a_complex_reg && !b_complex_reg) begin
                                    // vector A is complex, vector B is real.
                                    // Real part: A_re * B_re
                                    // Imaginary part: A_im * B_re
                                    acc_re <= acc_re + (A_re * B_re)[15:0];
                                    acc_im <= acc_im + (A_im * B_re)[15:0];
                                end else if (!a_complex_reg && b_complex_reg) begin
                                    // vector A is real, vector B is complex.
                                    // Real part: A_re * B_re
                                    // Imaginary part: B_im * A_re
                                    acc_re <= acc_re + (A_re * B_re)[15:0];
                                    acc_im <= acc_im + (B_im * A_re)[15:0];
                                end
                            end
                        end
                        cnt <= cnt + 1;
                        // Check if all elements have been processed
                        if (cnt == dot_length_reg - 1)
                            state <= OUTPUT;
                        else
                            state <= COMPUTE;
                    end
                end

                OUTPUT: begin
                    // Drive the output based on mode
                    if (!a_complex_reg && !b_complex_reg) begin
                        // Real-Only Mode: output the 32-bit accumulator (upper 16 bits zero)
                        dot_product_out <= acc;
                    end else begin
                        // Complex Mode: concatenate imaginary and real parts
                        dot_product_out <= {acc_im[15:0], acc_re[15:0]};
                    end
                    dot_product_valid_out <= 1'b1;
                    state <= IDLE;
                end

                ERROR: begin
                    // In ERROR state, assert error output and hold outputs inactive.
                    dot_product_out     <= 32'd0;
                    dot_product_valid_out <= 1'b0;
                    dot_product_error_out <= 1'b1;
                    // Remain in ERROR state until an external reset is applied.
                    state <= ERROR;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule