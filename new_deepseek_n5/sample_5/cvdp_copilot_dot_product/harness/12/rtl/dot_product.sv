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
    reg [31:0] acc;
    reg [6:0] cnt;
    reg vector_a_valid_in;
    reg vector_b_valid_in;

    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state <= IDLE;
            acc <= 0;
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
                        acc <= 0;
                        cnt <= 0;
                    end
                end
                COMPUTE: begin
                    if (vector_a_valid_in && vector_b_valid_in) begin
                        acc <= acc + (vector_a_in * vector_b_in);
                        cnt <= cnt + 1;
                    end
                    if (cnt == dot_length_in - 1) begin
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

    always @(posedge clk_in) begin
        dot_product_valid_out <= state == OUTPUT;
    end

endmodule