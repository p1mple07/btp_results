module continuous_adder #(
    parameter DATA_WIDTH = 32,                  // Parameter for data width, default is 32 bits
    parameter THRESHOLD_VALUE_1 = 50,            // Configurable threshold value 1, default is 50
    parameter THRESHOLD_VALUE_2 = 100,            // Configurable threshold value 2, default is 100
    parameter SIGNED_INPUTS = 1,                 // Parameter to enable signed inputs (1 = signed, 0 = unsigned), default is 1
    parameter ACCUM_MODE = 0,                   // Configurable accumulation mode, default is 0
    parameter WEIGHT = 1                      // Configurable weight for input data, default is 1
) (
    input logic clk,                        // Clock signal
    input logic reset,                     // Reset signal, Active high and Synchronous
    input logic signed [DATA_WIDTH-1:0] data_in,    // Signed or unsigned input data stream, parameterized width
    input logic data_valid,              // Input data valid signal
    output logic signed [DATA_WIDTH-1:0] sum_out,    // Accumulated sum output, parameterized width
    output logic threshold_1,             // High signal when sum crosses THRESHOLD_VALUE_1
    output logic threshold_2,            // High signal when sum crosses THRESHOLD_VALUE_2
    output logic sum_ready,              // Signal indicating sum is ready to be read
    input logic [15:0] window_size,        // Window size for averaging, used only in ACCUM_MODE = 1
    output logic avg_out               // Average output, used only in ACCUM_MODE = 1
) (
    input logic signed [DATA_WIDTH-1:0] weighted_input,  // Weighted input
    logic signed [DATA_WIDTH-1:0] sum_accum,    // Internal accumulator to store the running sum
    logic sum_ready_reg               // Internal signal indicating that sum_out should be updated
);

    // Combinational signals for threshold detection
    logic threshold_1_comb,
    logic threshold_2_comb;

    // Accumulation logic
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator
            sum_accum <= {DATA_WIDTH{1'b0}};
            sum_ready_reg <= 1'b0;
            threshold_1 <= 1'b0;
            threshold_2 <= 1'b0;
            sum_out <= {DATA_WIDTH{1'b0}};
        end else begin
            if (data_valid) begin
                // Apply weight to input data
                weighted_input <= data_in * WEIGHT;

                // Accumulate weighted input
                sum_accum <= sum_accum + weighted_input;

                // Check thresholds
                if (ACCUM_MODE == 0) begin
                    if ((sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1)) begin
                        threshold_1 <= 1'b1;
                        threshold_2 <= 1'b0;
                        sum_out <= sum_accum;
                        sum_ready_reg <= 1'b1;
                    end else begin
                        threshold_1 <= 1'b0;
                        threshold_2 <= 1'b0;
                        sum_ready_reg <= 1'b0;
                    end
                end else if (ACCUM_MODE == 1) begin
                    if (sample_count == window_size) begin
                        if ((sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1)) begin
                            threshold_1 <= 1'b1;
                            threshold_2 <= 1'b1;
                            sum_out <= sum_accum;
                            sum_ready_reg <= 1'b1;
                        end else begin
                            threshold_1 <= 1'b0;
                            threshold_2 <= 1'b0;
                            sum_ready_reg <= 1'b0;
                        end
                    end
                end
                sample_count <= sample_count + 1;
            end
        end
    end

    // Window-based mode logic
    always @(posedge clk) begin
        if (reset) begin
            sum_ready_reg <= 1'b0;
            sample_count <= 0;
            avg_out <= {DATA_WIDTH{1'b0}};
        end else if (ACCUM_MODE == 1) begin
            if (sample_count == window_size) begin
                avg_out <= sum_accum / WEIGHT;
                sum_ready_reg <= 1'b1;
                sum_accum <= {DATA_WIDTH{1'b0}};
                sample_count <= 0;
            end
        end
    end

endmodule
