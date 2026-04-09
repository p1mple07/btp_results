module low_pass_filter #(parameter DATA_WIDTH = 16, parameter COEFF_WIDTH = 16, parameter NUM_TAPS = 8)
(
    input clk,
    input reset,
    input [DATA_WIDTH * NUM_TAPS - 1:0] data_in,
    input valid_in,
    input [COEFF_WIDTH * NUM_TAPS - 1:0] coeffs,
    output reg [(DATA_WIDTH + COEFF_WIDTH) + ($clog2(NUM_TAPS)) - 1:0] data_out,
    output reg valid_out
);

    // Internal signal breakdown

    // 2D Internal Representation
    reg [DATA_WIDTH - 1:0] internal_data_in [NUM_TAPS - 1:0];
    reg [COEFF_WIDTH - 1:0] internal_coeffs [NUM_TAPS - 1:0];

    // Register inputs on validity signal
    always @(posedge clk) begin
        if (reset) begin
            internal_data_in <= {DATA_WIDTH{0}};
            internal_coeffs <= {COEFF_WIDTH{0}};
            valid_out <= 1'b0;
        end else if (valid_in) begin
            internal_data_in <= data_in;
            internal_coeffs <= coeffs;
            valid_out <= 1'b1;
        end
    end

    // Convert 1D to 2D for efficient computation
    always @* begin
        internal_data_in = {internal_data_in[NUM_TAPS - 1], internal_data_in[NUM_TAPS - 2]};
        internal_coeffs = {internal_coeffs[NUM_TAPS - 1], internal_coeffs[NUM_TAPS - 2]};
    end

    // Element-wise multiplication and summation
    always @(posedge clk) begin
        if (valid_in) begin
            integer i;
            reg [DATA_WIDTH * COEFF_WIDTH - 1:0] intermediate_sum = 0;
            for (i = 0; i < NUM_TAPS; i = i + 1) begin
                intermediate_sum = intermediate_sum +
                    internal_data_in[NUM_TAPS - i - 1] * internal_coeffs[NUM_TAPS - i - 1];
            end
            data_out <= intermediate_sum;
        end
    end

    // Reset behavior
    always @(posedge clk) begin
        if (reset) begin
            data_out <= {DATA_WIDTH+COEFF_WIDTH{0}};
            valid_out <= 1'b0;
        end
    end

endmodule
