module continuous_adder #(
    parameter DATA_WIDTH = 32,                  // Parameter for data width, default is 32 bits
    parameter THRESHOLD_VALUE_1 = 50,            // Configurable threshold value 1, default is 50
    parameter THRESHOLD_VALUE_2 = 100,          // Configurable threshold value 2, default is 100
    parameter SIGNED_INPUTS = 1,               // Parameter to enable signed inputs (1 = signed, 0 = unsigned)
    parameter ACCUM_MODE = 0,                // Configurable accumulation mode, default is threshold-based continuous accumulation
    parameter WEIGHT = 1                   // Configurable weight for input data, default is 1
) (
    input logic clk,                      // Clock signal
    input logic reset,                    // Reset signal, Active high and Synchronous
    input logic signed [DATA_WIDTH-1:0] data_in,    // Signed or unsigned input data stream, parameterized width
    input logic data_valid,            // Input data valid signal
    output logic signed [DATA_WIDTH-1:0] sum_out,    // Accumulated sum output, parameterized width
    output logic threshold_1,          // High when sum crosses THRESHOLD_VALUE_1
    output logic threshold_2,          // High when sum crosses THRESHOLD_VALUE_2
    output logic sum_ready,           // Indicates that sum_out is valid and can be read
    input logic [DATA_WIDTH-1:0] window_size,    // Window size for averaging mode, ignored in continuous mode

    // Internal accumulator register
    logic signed [DATA_WIDTH-1:0] sum_accum,

    // Weighted input
    logic signed [DATA_WIDTH-1:0] weighted_input,

    // Sample count for averaging mode
    logic [15:0] sample_count,

    // Combinational signals for threshold detection
    logic threshold_1_comb,
    logic threshold_2_comb
) (
    input logic signed [DATA_WIDTH-1:0] weighted_data_in,

    // Accumulation behavior
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator
            sum_accum <= {DATA_WIDTH{1'b0}};
            sum_ready <= 1'b0;
            threshold_1 <= 1'b0;
            threshold_2 <= 1'b0;
        end
        else begin
            if (data_valid) begin
                // Apply weight to input data
                weighted_data_in <= data_in * WEIGHT;

                // Accumulate weighted input
                sum_accum <= sum_accum + weighted_data_in;

                // Update sample count if in averaging mode
                if (ACCUM_MODE == 1) begin
                    if (sample_count == window_size) begin
                        sample_count <= 0;
                        avg_out <= sum_accum / WEIGHT;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                // Check if the accumulated sum crosses the thresholds
                if (ACCUM_MODE == 0) begin
                    if (SIGNED_INPUTS) begin
                        if ((sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1)) begin
                            threshold_1 <= 1'b1;
                            sum_ready <= 1'b1;
                        end else begin
                            threshold_1 <= 1'b0;
                            sum_ready <= 1'b0;
                        end
                    end else begin
                        if (sum_accum >= THRESHOLD_VALUE_2) begin
                            threshold_2 <= 1'b1;
                            sum_ready <= 1'b1;
                        end else begin
                            threshold_2 <= 1'b0;
                            sum_ready <= 1'b0;
                        end
                    end
                end else begin
                    if (sum_accum + weighted_data_in >= THRESHOLD_VALUE_1) begin
                        threshold_1 <= 1'b1;
                        sum_ready <= 1'b1;
                    end
                    else begin
                        threshold_1 <= 1'b0;
                        sum_ready <= 1'b0;
                    end
                end

                if (ACCUM_MODE == 1) begin
                    if (sample_count == window_size) begin
                        threshold_1 <= 1'b0;
                        threshold_2 <= 1'b0;
                        sum_ready <= 1'b1;
                    end else begin
                        threshold_1 <= 1'b0;
                        threshold_2 <= 1'b0;
                        sum_ready <= 1'b0;
                    end
                end
            end
        end
    end

    // Averaging output in Window-Based Mode
    assign avg_out = (ACCUM_MODE == 1) && (sample_count == window_size) ? sum_accum / WEIGHT : 1'b0;
)
