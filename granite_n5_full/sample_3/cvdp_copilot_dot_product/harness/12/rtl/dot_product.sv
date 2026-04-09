module dot_product (
    input wire clock,
    input wire reset,
    input wire start,
    input wire [6:0] dot_length,
    input wire [7:0] vector_a,
    input wire vector_a_valid,
    input wire [15:0] vector_b,
    input wire vector_b_valid,
    output reg [31:0] dot_product,
    output reg dot_product_valid
);
    typedef enum logic [1:0] {
        IDLE,
        COMPUTE,
        OUTPUT
    } state_t;

    state_t state;
    reg [31:0] acc;
    reg [6:0] cnt;
    reg [6:0] dot_length_reg;
    reg vector_a_valid_in_prev;
    reg vector_b_valid_in_prev;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            acc <= 0;
            cnt <= 0;
            dot_product <= 0;
            dot_product_valid <= 0;
            dot_length_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    dot_product_valid <= 0;
                    dot_length_reg <= dot_length;
                    if (start) begin
                        state <= COMPUTE;
                        acc <= 0;
                        cnt <= 0;
                    end
                end
                COMPUTE: begin
                    if (vector_a_valid && vector_b_valid) begin
                        acc <= acc + (vector_a * vector_b);
                        cnt <= cnt + 1;
                    end
                    if (cnt == dot_length_reg - 1) begin
                        state <= OUTPUT;
                    end else begin
                        state <= COMPUTE;
                    end
                end
                OUTPUT: begin
                    dot_product <= acc;
                    dot_product_valid <= 1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    assign dot_product_valid = (state == OUTPUT);

endmodule