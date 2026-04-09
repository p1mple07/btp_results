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
    int acc;

    initial begin
        state = IDLE;
    end

    always @(posedge clk_in) begin
        case (state)
            IDLE: begin
                if (start_in) begin
                    state <= COMPUTE;
                end
            end
            COMPUTE: begin
                if (dot_length_in > 0) begin
                    for (int i = 0; i < dot_length_in; i++) begin
                        if (vector_a_valid_in[i] && vector_b_valid_in[i]) begin
                            acc += vector_a_in[i] * vector_b_in[i];
                        end
                    end
                end
                if (dot_length_in == 0) begin
                    dot_product_out = 32'h0;
                    dot_product_valid_out = 0;
                } else begin
                    dot_product_out = acc;
                    dot_product_valid_out = 1;
                end
            end
            OUTPUT: begin
                dot_product_out = dot_product;
                dot_product_valid_out = 1;
            end
        end
    end

    always @(*) begin
        dot_length = dot_length_in;
        if (dot_length_in > 0) begin
            acc = 0;
        end
    end

    always @(*) begin
        if (reset_in) begin
            state <= IDLE;
            acc = 0;
            dot_product_out = 0;
            dot_product_valid_out = 0;
        end
    end

endmodule
