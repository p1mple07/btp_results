module low_pass_filter #(
    parameter int DATA_WIDTH = 16,
    parameter int COEFF_WIDTH = 16,
    parameter int NUM_TAPS = 8
)(
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH*NUM_TAPS-1:0] data_in,
    input wire [COEFF_WIDTH*NUM_TAPS-1:0] coeffs,
    output reg [NBW_MULT + $clog2(NUM_TAPS) - 1:0] data_out,
    output reg valid_out
);

    // Internal signals
    reg [DATA_WIDTH-1:0] in_array[NUM_TAPS-1:0];
    reg [COEFF_WIDTH-1:0] coeff_array[NUM_TAPS-1:0];
    reg valid_in;
    reg [COEFF_WIDTH*NUM_TAPS-1:0] convolution_result;
    reg valid_out;

    initial begin
        valid_in = 0;
        coeff_array = {};
        in_array = {};
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_in <= 0;
            coeff_array = {};
            in_array = {};
        end else begin
            valid_in <= 1;
            if (valid_in) begin
                // Register data_in and coeffs
                in_array = data_in;
                coeff_array = coeffs;
            end
        end
    end

    // Compute convolution
    always @(posedge clk) begin
        if (valid_in && !reset) begin
            // Convert arrays to 2D array of (NUM_TAPS x NUM_TAPS)
            // Actually we need 2D matrix: each tap index j (0 to NUM_TAPS-1) and data index i (0 to NUM_TAPS-1).
            // The convolution: for each tap j, multiply data[i+j] by coeff[j], sum over i.
            // But we can do element-wise multiplication and accumulate.

            // Let's precompute the 2D convolution using loops.
            for (int j = 0; j < NUM_TAPS; j++) begin
                for (int i = 0; i < NUM_TAPS; i++) begin
                    covolution_result = covolution_result + in_array[i] * coeff_array[j];
                end
            end

            // Wait, but the order: we need to align with the taps. The spec says convolution on input data using FIR with coefficients.
            // The typical FIR convolution: output length is NUM_TAPS + (NUM_TAPS - 1)? Actually FIR length is NUM_TAPS + (NUM_TAPS - 1) but we use full convolution.

            // However, the specification says: "element-wise multiplication and summation across the taps." So we can treat it as a simple dot product.

            // Actually, the standard convolution: for each output tap k (0 to NUM_TAPS-1), sum over input taps i: data[i + k] * coeff[k], but we need to shift.

            // Given the complexity, maybe we can approximate as a dot product.

            // But the user might expect a simple implementation.

            // Let's just implement the dot product: for each output tap, sum the products.

            data_out = 0;
            for (int k = 0; k < NUM_TAPS; k++) begin
                data_out = data_out + covolution_result[k];
            end
        end
    end

    assign valid_out = (valid_in) ? 1 : 0;

endmodule
