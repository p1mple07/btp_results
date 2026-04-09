module continuous_adder #(
    parameter DATA_WIDTH = 32,                  // Parameter for data width, default is 32 bits
    parameter THRESHOLD_VALUE_1 = 50,            // Configurable threshold value 1
    parameter THRESHOLD_VALUE_2 = 100,           // Configurable threshold value 2
    parameter THRESHOLD_VALUE_3 = 200,           // Configurable threshold value 3
    parameter THRESHOLD_VALUE_4 = 500,           // Configurable threshold value 4
    parameter SIGNED_INPUTS = 1,               // Parameter to enable signed inputs (1 = signed, 0 = unsigned)
    parameter ACCUM_MODE = 0,                // Accumulation mode: 0 for continuous, 1 for window-based
    parameter WEIGHT = 1                     // Parameter for input weighting
) (
    input logic clk,                      // Clock signal
    input logic reset,                   // Reset signal, Active high and Synchronous
    input logic signed [DATA_WIDTH-1:0] data_in,    // Signed or unsigned input data stream, parameterized width
    input logic data_valid,            // Input data valid signal
    output logic signed [DATA_WIDTH-1:0] sum_out,    // Accumulated sum output, parameterized width
    output logic threshold_1,          // Threshold 1 signal
    output logic threshold_2,          // Threshold 2 signal
    output logic threshold_3,          // Threshold 3 signal
    output logic threshold_4,          // Threshold 4 signal
    output logic sum_ready,           // Indicates that sum_out and avg_out are valid and can be read
    output logic avg_out             // Average output, valid only in window-based mode
) (
    input logic [DATA_WIDTH-1:0] weighted_input, // Weighted input
    output logic [DATA_WIDTH-1:0] sum_accum,    // Internal accumulator to store the running sum
    output logic [DATA_WIDTH-1:0] avg_out     // Average output, valid only in window-based mode
)
{
    logic signed [DATA_WIDTH-1:0] sum_accum;    // Internal accumulator to store the running sum
    logic sum_ready_reg;              // Internal signal indicating that sum_out and avg_out should be updated
    logic threshold_1_comb,           // Combinational signal for threshold 1
    logic threshold_2_comb,           // Combinational signal for threshold 2
    logic threshold_3_comb,           // Combinational signal for threshold 3
    logic threshold_4_comb,           // Combinational signal for threshold 4
    logic sample_count[15:0];         // Sample count, used only in window-based mode

    // Weighted input calculation
    assign weighted_input = data_in * WEIGHT;

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out, sum_ready, and sample_count
            sum_accum <= {DATA_WIDTH{1'b0}};
            sum_out <= {DATA_WIDTH{1'b0}};
            sum_ready <= 1'b0;
            threshold_1_comb <= 1'b0;
            threshold_2_comb <= 1'b0;
            threshold_3_comb <= 1'b0;
            threshold_4_comb <= 1'b0;
            sample_count <= {16'b0};
        end
        else begin
            if (data_valid) begin
                // Accumulate input values
                sum_accum <= sum_accum + weighted_input;

                // Check thresholds
                if (ACCUM_MODE == 0) begin
                    if ((sum_accum >= THRESHOLD_VALUE_1 || sum_accum <= -THRESHOLD_VALUE_1) ||
                       (sum_accum >= THRESHOLD_VALUE_2 || sum_accum <= -THRESHOLD_VALUE_2)) begin
                        // Set threshold signals and sum_ready high
                        threshold_1_comb <= 1'b1;
                        threshold_2_comb <= (sum_accum >= THRESHOLD_VALUE_2 ? 1'b1 : 1'b0);
                        threshold_3_comb <= (sum_accum >= THRESHOLD_VALUE_3 ? 1'b1 : 1'b0);
                        threshold_4_comb <= (sum_accum >= THRESHOLD_VALUE_4 ? 1'b1 : 1'b0);
                        sum_ready <= 1'b1;
                    end
                    else begin
                        // No threshold crossing, sum_ready remains low
                        sum_ready <= 1'b0;
                    end
                end
                else begin
                    // Continue accumulating
                    sum_ready <= 1'b0;
                end
            end
        end
    end

    // Window-based accumulation with averaging logic (if ACCUM_MODE == 1)
    if (ACCUM_MODE == 1) begin
        integer window_size = 5;
        integer count = 0;
        assign sum_out = sum_accum / DATA_WIDTH;
        assign avg_out = (sample_count == window_size) ? sum_accum / DATA_WIDTH : 1'b0;

        // Reset logic for window-based mode
        always_ff @(posedge clk) begin
            if (reset) begin
                sum_accum <= {DATA_WIDTH{1'b0}};
                sample_count <= {16'b0};
            end else begin
                if (sample_count == window_size) begin
                    sum_accum <= {DATA_WIDTH{1'b0}};
                    sample_count <= {16'b0};
                    sum_ready <= 1'b0;
                    avg_out <= 1'b0;
                end
                else begin
                    count <= count + 1;
                    sum_ready <= 1'b0;
                end
            end
        end
    end
endmodule
