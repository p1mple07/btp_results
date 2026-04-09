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
    
    // Registers for iteration and accumulation
    reg [6:0] counter;
    reg [31:0] acc;
    // Register to implement output latency (one extra cycle)
    reg out_delay;

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state             <= IDLE;
            counter           <= 7'd0;
            acc               <= 32'd0;
            dot_product_out   <= 32'd0;
            dot_product_valid_out <= 1'b0;
            out_delay         <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    // Wait for start signal to initiate computation
                    if (start_in) begin
                        state   <= COMPUTE;
                        counter <= 7'd0;
                        acc     <= 32'd0;
                    end
                end
                COMPUTE: begin
                    // Process each element until the counter reaches the dynamic length
                    if (counter < dot_length_in) begin
                        // Only accumulate when both input valid signals are asserted
                        if (vector_a_valid_in && vector_b_valid_in)
                            acc <= acc + (vector_a_in * vector_b_in);
                        counter <= counter + 1;
                    end else begin
                        // Finished computing, move to OUTPUT state
                        state <= OUTPUT;
                        counter <= 7'd0; // Clear counter (not used further)
                    end
                end
                OUTPUT: begin
                    // Implement a two-cycle latency for the output.
                    // In the first cycle of OUTPUT state, set the delay flag.
                    // In the next cycle, assign the accumulated result and deassert the state.
                    if (out_delay == 1'b0) begin
                        out_delay <= 1'b1;
                    end else begin
                        dot_product_out     <= acc;
                        dot_product_valid_out <= 1'b1;
                        state               <= IDLE;
                        out_delay           <= 1'b0;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule