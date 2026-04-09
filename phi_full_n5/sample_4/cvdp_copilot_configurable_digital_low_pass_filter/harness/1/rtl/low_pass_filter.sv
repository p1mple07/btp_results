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
    output reg [(DATA_WIDTH + COEFF_WIDTH + $clog2(NUM_TAPS) + 1) - 1:0] data_out,
    output reg valid_out
);

    // Internal signals
    reg [DATA_WIDTH * NUM_TAPS - 1:0] data_reg;
    reg [COEFF_WIDTH * NUM_TAPS - 1:0] coeffs_reg;
    reg [DATA_WIDTH + COEFF_WIDTH - 1:0] temp_sum;

    // Calculate intermediate multiplication width
    localparam NBW_MULT = DATA_WIDTH + COEFF_WIDTH;

    // Internal logic
    always @(posedge clk) begin
        if (reset) begin
            data_reg <= {DATA_WIDTH{1'b0}};
            coeffs_reg <= {COEFF_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else begin
            if (valid_in) begin
                data_reg <= data_in;
                coeffs_reg <= coeffs;
                valid_out <= 1'b1;
            end
        end
    end

    // Convolution operation
    always @(posedge clk) begin
        if (valid_in) begin
            // Element-wise multiplication
            for (int i = 0; i < NUM_TAPS; i++) begin
                temp_sum = temp_sum + data_reg[(i * DATA_WIDTH) +: DATA_WIDTH] * coeffs_reg[(NUM_TAPS - 1 - i) * COEFF_WIDTH +: COEFF_WIDTH];
            end
        end

        // Update output
        data_out <= temp_sum;
    end

endmodule
