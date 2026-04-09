`timescale 1ns / 1ps

module dot_product (
    input               clk_in,
    input               reset_in,
    input               start_in,
    input       [6:0]   dot_length_in,
    input               [7:0]   vector_a_in,
    input               vector_a_valid_in,
    input       [15:0]  vector_b_in,
    input               vector_b_valid_in,
    output reg  [31:0]  dot_product_out,
    output reg          dot_product_valid_out,
    output reg          dot_product_error_out
);

    // --- State definitions -------------------------------------------------
    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        COMPUTE     = 2'b01,
        OUTPUT      = 2'b10
    } state_t;

    state_t state;
    reg [31:0] acc;
    reg [6:0] cnt;
    reg [6:0] dot_length_reg;
    reg vector_a_valid_in_prev;
    reg vector_b_valid_in_prev;

    // --- Input/Output register declarations -------------------------------
    reg [31:0] dot_product_out;
    reg dot_product_valid_out;

    // --- Internal registers ----------------------------------------------
    reg [31:0] vector_a_reg;
    reg [31:0] vector_b_reg;
    reg [6:0] dot_product_acc;
    reg dot_product_dot_valid;

    // --- Initialisation ----------------------------------------------------
    initial begin
        state        <= IDLE;
        acc          <= 0;
        cnt          <= 0;
        dot_product_out <= 32'd0;
        dot_product_valid_out <= 0;
        dot_product_error_out <= 0;
        dot_length_reg <= 0;
        vector_a_reg <= 0;
        vector_b_reg <= 0;
    end

    // --- Combinational logic ---------------------------------------------
    always @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            state        <= IDLE;
            acc          <= 0;
            cnt          <= 0;
            dot_product_out <= 0;
            dot_product_valid_out <= 0;
            dot_product_error_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    dot_product_valid_out <= 0;
                    dot_product_error_out <= 0;
                    dot_length_reg <= dot_length_in;
                    if (start_in) begin
                        state        <= COMPUTE;
                        acc          <= 0;
                        cnt          <= 0;
                    end
                end
                COMPUTE: begin
                    if (vector_a_valid_in && vector_b_valid_in) begin
                        dot_product_acc <= vector_a_in * vector_b_in;
                        cnt <= cnt + 1;
                    end
                    if (cnt == dot_length_reg - 1) begin
                        state        <= OUTPUT;
                    end else begin
                        state        <= COMPUTE;
                    end
                end
                OUTPUT: begin
                    dot_product_out <= dot_product_acc;
                    dot_product_valid_out <= 1;
                    dot_product_error_out <= 0;
                    state        <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
