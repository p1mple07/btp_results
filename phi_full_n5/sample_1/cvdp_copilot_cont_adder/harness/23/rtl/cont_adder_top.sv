module continuous_adder #(
    parameter DATA_WIDTH = 16,                  // Parameter for data width, default is 16 bits
    parameter THRESHOLD_VALUE_1 = 50,            // Configurable threshold value 1, default is 50
    parameter THRESHOLD_VALUE_2 = 100,           // Configurable threshold value 2, default is 100
    parameter SIGNED_INPUTS = 1,                 // Enable signed inputs (1 = signed, 0 = unsigned), default is 1
    parameter ACCUM_MODE = 0,                 // Accumulation mode: 0 for continuous, 1 for window-based
    parameter WEIGHT = 2                     // Configurable weight for input data, default is 2
) (
    input logic clk,                        // Clock signal
    input logic reset,                     // Reset signal, Active high and Synchronous
    input logic signed [DATA_WIDTH-1:0] data_in,    // Signed or unsigned input data stream, parameterized width
    input logic data_valid,              // Input data valid signal
    output logic signed [DATA_WIDTH-1:0] sum_out,    // Accumulated sum output, parameterized width
    output logic threshold_1,            // Threshold 1 signal
    output logic threshold_2,            // Threshold 2 signal
    output logic sum_ready,             // Signal to indicate sum is output and accumulator is reset
    input logic [DATA_WIDTH-1:0] window_size,  // Window size for averaging, used only in ACCUM_MODE = 1
    output logic avg_out               // Average output, used only in ACCUM_MODE = 1
) (
    logic signed [DATA_WIDTH-1:0] sum_accum;    // Internal accumulator to store the running sum
    logic [15:0] sample_count;          // Sample count for averaging, used only in ACCUM_MODE = 1
    logic weighted_input;             // Weighted input

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out, sum_ready, and sample_count
            sum_accum <= {DATA_WIDTH{1'b0}};
            sum_ready <= 1'b0;
            sum_out <= {DATA_WIDTH{1'b0}};
            sample_count <= 16'b0;
        end
        else begin
            if (data_valid) begin
                // Apply weight to input data
                weighted_input = data_in * WEIGHT;

                // Accumulate weighted input
                sum_accum     <= sum_accum + weighted_input;

                // Threshold checks
                if(SIGNED_INPUTS) begin
                    if ((sum_accum + weighted_input >= THRESHOLD_VALUE_1) || (sum_accum + weighted_input <= -1*THRESHOLD_VALUE_1)) begin
                        // Set threshold signals high
                        threshold_1 <= 1'b1;
                        threshold_2 <= 1'b0;
                        // Output the accumulated sum and reset the accumulator
                        sum_out   <= sum_accum + weighted_input;
                        sum_ready <= 1'b1;
                        sum_accum <= {DATA_WIDTH{1'b0}};
                    end else if ((sum_accum + weighted_input >= THRESHOLD_VALUE_2) || (sum_accum + weighted_input <= -1*THRESHOLD_VALUE_2)) begin
                        // Set threshold signals high
                        threshold_1 <= 1'b0;
                        threshold_2 <= 1'b1;
                        // Output the accumulated sum and reset the accumulator
                        sum_out   <= sum_accum + weighted_input;
                        sum_ready <= 1'b1;
                        sum_accum <= {DATA_WIDTH{1'b0}};
                    end
                    else begin
                        // Continue accumulating, no output until thresholds are crossed
                        sum_ready <= 1'b0;
                    end
                end else begin
                    // Continue accumulating, no output until thresholds are crossed
                    sum_ready <= 1'b0;
                end
            end
        end
    end

    // Window-based mode (averaging) logic
    always @(posedge clk) begin
        if (ACCUM_MODE == 1 && sample_count == window_size) begin
            // Calculate and output average
            avg_out <= sum_accum / WEIGHT;
            // Reset accumulator and sample count
            sum_accum <= {DATA_WIDTH{1'b0}};
            sample_count <= 16'b0;
        end
    end
)
