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
    output reg          dot_product_valid_out,
    output reg          dot_product_error_out
);

    parameter MODEL = 2; // 0: real-only, 1: complex-only, 2: mixed
    localparam CASE MODEL = 0, 1, 2;

    // Internal registers
    reg [6:0] acc;
    reg [31:0] dot_product_out;
    reg dot_product_valid_out;
    reg dot_product_error_out;
    reg [6:0] cnt;
    reg [6:0] dot_length_reg;
    reg vector_a_valid_in_prev;
    reg vector_b_valid_in_prev;

    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state <= IDLE;
            acc <= 0;
            cnt <= 0;
            dot_product_out <= 0;
            dot_product_valid_out <= 0;
            dot_product_error_out <= 0;
            dot_length_reg <= 0;
        end else begin
            case (MODEL)
                0 : // Real-Only Mode
                    dot_product_valid_out <= 0;
                    dot_length_reg <= dot_length_in;
                    if (start_in) begin
                        state <= COMPUTE;
                        acc <= 0;
                        cnt <= 0;
                    end
                end
                1 : // Complex-Only Mode
                    dot_product_valid_out <= 0;
                    dot_length_reg <= dot_length_in;
                    if (start_in) begin
                        state <= COMPUTE;
                        acc <= 0;
                        cnt <= 0;
                    end
                end
                2 : // Mixed Mode
                    dot_product_valid_out <= 0;
                    dot_length_reg <= dot_length_in;
                    if (start_in) begin
                        state <= COMPUTE;
                        acc <= 0;
                        cnt <= 0;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    always @(posedge clk_in or negedge reset_in) begin
        if (reset_in) begin
            state <= IDLE;
            dot_product_out <= 0;
            dot_product_valid_out <= 0;
            dot_product_error_out <= 0;
        end else begin
            if (dot_product_valid_out) begin
                dot_product_valid_out <= 1;
                dot_product_error_out <= 0;
            end else begin
                dot_product_error_out <= 1;
            end
        end
    end

endmodule
