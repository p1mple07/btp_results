module low_pass_filter #(
    parameter int DATA_WIDTH = 16,
    parameter int COEFF_WIDTH = 16,
    parameter int NUM_TAPS = 8
) (
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH*NUM_TAPS-1:0] data_in,
    input wire valid_in,
    input wire [COEFF_WIDTH*NUM_TAPS-1:0] coeffs,
    output wire [$(NBW_MULT)+$clog2(NUM_TAPS)-1:0] data_out,
    output wire valid_out
);

    //... (internal signals and register definitions)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset logic here
        end else begin
            // Register input data
            // Convert input data to 2D array
            // Perform element-wise multiplication
            // Accumulate intermediate multiplication results
            // Compute final summation result
            // Assign the final result to data_out
            // Update the validity signal for output data
        end
    end

endmodule