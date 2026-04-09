module dot_product (
    input               clk_in,
    input               reset_in,
    input               start_in,
    input       [6:0]   dot_length_in,
    input       [7:0]   vector_a_in,
    input               vector_a_valid_in,
    input       [15:0]  vector_b_in,
    input               vector_b_valid_in,
    output reg  [31:0]  dot_product_out,
    output reg          dot_product_valid_out
);

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        OUTPUT  = 2'b10
    } state_t;

    state_t state;
    
    initial begin
        state <= IDLE;
    end

    always @(posedge clk_in) begin
        if (reset_in) begin
            state <= IDLE;
        end else if (start_in) begin
            state <= COMPUTE;
        end else
            state <= IDLE;
    end

    always @(state) begin
        case (state)
            IDLE: begin
                // No action
            end
            COMPUTE: begin
                accumulator = 0;
                for (integer i = 0; i < dot_length_in; i++) begin
                    if (vector_a_valid_in && vector_b_valid_in) begin
                        accumulator += vector_a_in[i] * vector_b_in[i];
                    end
                end
                dot_product_out = accumulator;
                dot_product_valid_out = 1;
            end
            OUTPUT: begin
                // Just output the existing values; no change needed.
            end
        endcase
    end

endmodule
