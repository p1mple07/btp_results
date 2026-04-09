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
    
    // Register to accumulate the dot product result
    reg [31:0] product_reg;
    // Counter to track the number of elements processed
    reg [6:0] counter;
    // Register to implement two-cycle output latency
    reg [1:0] out_latency_counter;

    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state              <= IDLE;
            product_reg        <= 32'd0;
            counter            <= 7'd0;
            dot_product_out    <= 32'd0;
            dot_product_valid_out <= 1'b0;
            out_latency_counter<= 2'd0;
        end
        else begin
            case (state)
                IDLE: begin
                    // Wait for start signal; then initialize and start computation
                    if (start_in) begin
                        product_reg    <= 32'd0;
                        counter        <= dot_length_in;
                        state          <= COMPUTE;
                    end
                end
                COMPUTE: begin
                    if (counter != 0) begin
                        // Only accumulate if both inputs are valid
                        if (vector_a_valid_in && vector_b_valid_in)
                            product_reg <= product_reg + ({8'd0, vector_a_in} * vector_b_in);
                        counter <= counter - 1;
                        // Once all elements are processed, move to OUTPUT state
                        if (counter == 0)
                            state <= OUTPUT;
                    end
                end
                OUTPUT: begin
                    // Implement two-cycle latency before driving the output
                    if (out_latency_counter < 2)
                        out_latency_counter <= out_latency_counter + 1;
                    else begin
                        dot_product_out      <= product_reg;
                        dot_product_valid_out<= 1'b1;
                        state                <= IDLE;
                        out_latency_counter  <= 2'd0;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule