module low_pass_filter #(
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH = 16,
    parameter NUM_TAPS = 8
) (
    input clk,
    input reset,
    input [DATA_WIDTH * NUM_TAPS - 1:0] data_in,
    input valid_in,
    input [COEFF_WIDTH * NUM_TAPS - 1:0] coeffs,
    output [DATA_WIDTH + COEFF_WIDTH + log2_num_taps(NUM_TAPS) - 1:0] data_out,
    output valid_out
);

    // Internal signal breakdown

    // 2D Internal Representation
    reg [DATA_WIDTH * NUM_TAPS - 1:0] data_reg;
    reg [COEFF_WIDTH * NUM_TAPS - 1:0] coeffs_reg;

    // Convert input data and coefficients to 2D arrays
    always_comb begin
        if (valid_in) begin
            data_reg = data_in;
            coeffs_reg = coeffs;
        end else begin
            data_reg = {DATA_WIDTH{data_reg[NUM_TAPS*DATA_WIDTH-1:0]}},
            coeffs_reg = {COEFF_WIDTH{coeffs_reg[NUM_TAPS*COEFF_WIDTH-1:0]}};
        end
    end

    // Element-wise multiplication
    always_comb begin
        if (valid_in) begin
            {valid_out, data_out} = #1 {
                valid_out = 1'b1,
                data_out = sum_2d_multiply(data_reg, coeffs_reg)
            };
        end else begin
            {valid_out, data_out} = #1 {
                valid_out = valid_in,
                data_out = {DATA_WIDTH{data_out[NUM_TAPS*DATA_WIDTH-1:0]}}
            };
        end
    end

    // Helper function to perform 2D multiplication and summation
    function [DATA_WIDTH + COEFF_WIDTH + log2_num_taps(NUM_TAPS) - 1:0] sum_2d_multiply(
        input reg [DATA_WIDTH * NUM_TAPS - 1:0] data_2d,
        input reg [COEFF_WIDTH * NUM_TAPS - 1:0] coeffs_2d
    );
        reg [DATA_WIDTH + COEFF_WIDTH + log2_num_taps(NUM_TAPS) - 1:0] sum_result;

        always_comb begin
            sum_result = {
                (NUM_TAPS - 1'b1) {1'b0}, // Pad with zeros
                {
                    (NUM_TAPS - 1) {coeffs_2d[NUM_TAPS*COEF_WIDTH-1], 1},
                    (NUM_TAPS - 2) {coeffs_2d[NUM_TAPS*COEF_WIDTH-2], 1},
                    // ...
                    (1) {coeffs_2d[NUM_TAPS*COEF_WIDTH-NUM_TAPS], 1}
                }
            };

            for (int i = 0; i < NUM_TAPS; i++) begin
                sum_result = sum_result + (data_2d[i*DATA_WIDTH +: DATA_WIDTH] & coeffs_2d[i*COEF_WIDTH +: COEFF_WIDTH])
            end
        end

        return sum_result;
    endfunction

    // Calculate log2_num_taps
    function logic [log2_num_taps(NUM_TAPS) - 1:0] log2_num_taps(input logic num_taps);
        return $clog2(num_taps);
    endfunction

endmodule
