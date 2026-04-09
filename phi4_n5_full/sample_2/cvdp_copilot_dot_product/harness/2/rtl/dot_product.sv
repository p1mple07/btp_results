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

    // State machine definition with an extra WAIT state for two-cycle latency
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10,
        WAIT    = 2'b11
    } state_t;

    state_t state;
    reg [31:0] accumulator;
    reg [6:0] counter;
    reg [31:0] dp_reg1, dp_reg2;
    reg valid_reg1;

    // Main state machine and accumulation logic
    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state          <= IDLE;
            accumulator    <= 32'd0;
            counter        <= 7'd0;
            dp_reg1        <= 32'd0;
            dp_reg2        <= 32'd0;
            valid_reg1     <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start_in) begin
                        state       <= COMPUTE;
                        accumulator <= 32'd0;
                        counter     <= 7'd0;
                    end
                end
                COMPUTE: begin
                    // Only perform multiplication when both valid signals are asserted
                    if (vector_a_valid_in && vector_b_valid_in) begin
                        accumulator <= accumulator + (vector_a_in * vector_b_in);
                        counter     <= counter + 1;
                        if (counter == dot_length_in - 1) begin
                            state <= OUTPUT;
                        end
                    end
                end
                OUTPUT: begin
                    // Latch the final accumulated result
                    dp_reg1 <= accumulator;
                    state   <= WAIT;
                end
                WAIT: begin
                    // Two-cycle latency pipeline stage: register the latched result
                    dp_reg2 <= dp_reg1;
                    valid_reg1 <= 1'b1;
                    state   <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    // Output register: drive outputs only in the WAIT state to meet the two-cycle latency requirement.
    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            dot_product_out    <= 32'd0;
            dot_product_valid_out <= 1'b0;
        end else begin
            case (state)
                WAIT: begin
                    dot_product_out    <= dp_reg2;
                    dot_product_valid_out <= valid_reg1;
                end
                default: begin
                    dot_product_valid_out <= 1'b0;
                end
            endcase
        end
    end

endmodule