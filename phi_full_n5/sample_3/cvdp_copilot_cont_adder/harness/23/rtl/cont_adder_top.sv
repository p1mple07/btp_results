module continuous_adder #(
    parameter DATA_WIDTH = 32,                  // Parameter for data width, default is 32 bits
    parameter THRESHOLD_VALUE_1 = 50,            // Configurable threshold value 1, default is 50
    parameter THRESHOLD_VALUE_2 = 100,          // Configurable threshold value 2, default is 100
    parameter SIGNED_INPUTS = 1,                 // Parameter to enable signed inputs (1 = signed, 0 = unsigned)
    parameter ACCUM_MODE = 0,                 // Configurable accumulation mode (0: continuous, 1: window-based)
    parameter WEIGHT = 1                     // Configurable weight for input data, default is 1
) (
    input logic clk,                      // Clock signal
    input logic reset,                    // Reset signal, Active high and Synchronous
    input logic signed [DATA_WIDTH-1:0] data_in,    // Signed or unsigned input data stream, parameterized width
    input logic data_valid,            // Input data valid signal
    output logic signed [DATA_WIDTH-1:0] sum_out,    // Accumulated sum output, parameterized width
    output logic threshold_1,           // Threshold 1 signal
    output logic threshold_2,           // Threshold 2 signal
    output logic sum_ready,            // Signal to indicate sum is ready
    output logic avg_out[DATA_WIDTH-1:0]   // Average output, parameterized width
) (
    input logic signed [DATA_WIDTH-1:0] weighted_input,  // Weighted input
    input logic [15:0] window_size        // Window size for window-based accumulation, used only if ACCUM_MODE = 1
);

    logic signed [DATA_WIDTH-1:0] sum_accum;    // Internal accumulator to store the running sum
    logic threshold_1_comb,           // Combinational signal for threshold 1
    logic threshold_2_comb;            // Combinational signal for threshold 2
    logic sum_ready_reg;              // Internal signal indicating that sum_out (and avg_out) should be updated

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out, sum_ready, and sample_count
            sum_accum <= {DATA_WIDTH{1'b0}};
            sum_out <= {DATA_WIDTH{1'b0}};
            threshold_1_comb <= 1'b0;
            threshold_2_comb <= 1'b0;
            sum_ready_reg <= 1'b0;
            avg_out <= {DATA_WIDTH{1'b0}};
        end
        else begin
            if (data_valid) begin
                // Apply weight to input data
                weighted_input <= data_in * WEIGHT;

                // Accumulate weighted input
                sum_accum <= sum_accum + weighted_input;

                // Check for threshold 1 crossing
                if (ACCUM_MODE == 0) begin
                    if ((sum_accum + weighted_input >= THRESHOLD_VALUE_1) || (sum_accum + weighted_input <= -THRESHOLD_VALUE_1)) begin
                        // Set threshold 1 signal high
                        threshold_1_comb <= 1'b1;
                        // Output the accumulated sum and reset sum_accum
                        sum_out <= sum_accum + weighted_input;
                        sum_ready_reg <= 1'b1;
                        sum_accum <= {DATA_WIDTH{1'b0}};
                    end else begin
                        threshold_1_comb <= 1'b0;
                        sum_ready_reg <= 1'b0;
                    end
                end

                // Check for threshold 2 crossing
                if (ACCUM_MODE == 0) begin
                    if ((sum_accum + weighted_input >= THRESHOLD_VALUE_2) || (sum_accum + weighted_input <= -THRESHOLD_VALUE_2)) begin
                        // Set threshold 2 signal high
                        threshold_2_comb <= 1'b1;
                        // Output the accumulated sum and reset sum_accum
                        sum_out <= sum_accum + weighted_input;
                        sum_ready_reg <= 1'b1;
                        sum_accum <= {DATA_WIDTH{1'b0}};
                    end else begin
                        threshold_2_comb <= 1'b0;
                        sum_ready_reg <= 1'b0;
                    end
                end

                // Window-based accumulation with averaging
                else if (ACCUM_MODE == 1) begin
                    if (sample_count == window_size) begin
                        // Calculate and output the average
                        avg_out <= sum_accum / WEIGHT;
                        sum_ready_reg <= 1'b1;
                        // Reset accumulator and sample count
                        sum_accum <= {DATA_WIDTH{1'b0}};
                        sample_count <= 16'd0;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
            end
        end
    end

    // Combinational logic for threshold signals
    always_comb begin
        threshold_1_comb = (sum_accum + weighted_input >= THRESHOLD_VALUE_1) || (sum_accum + weighted_input <= -THRESHOLD_VALUE_1);
        threshold_2_comb = (sum_accum + weighted_input >= THRESHOLD_VALUE_2) || (sum_accum + weighted_input <= -THRESHOLD_VALUE_2);
    end

endmodule
