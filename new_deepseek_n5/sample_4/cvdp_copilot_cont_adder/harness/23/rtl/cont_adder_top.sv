module continuous_adder #(
    parameter DATA_WIDTH = 32,
    parameter THRESHOLD_VALUE_1 = 50,
    parameter THRESHOLD_VALUE_2 = 100,
    parameter SIGNED_INPUTS = 1,
    parameter ACCUM_MODE = 0,
    parameter WEIGHT = 1,
    parameter window_size = 16
) (
    input logic clock, 
    input logic reset, 
    input logic data_valid,
    input logic data_in,
    input logic sum_ready,
    output logic sum_out,
    output logic sum_ready_window,
    output logic avg_out,
    output logic threshold_1,
    output logic threshold_2
);

    logic signed [DATA_WIDTH-1:0] sum_accum;
    logic signed [DATA_WIDTH-1:0] weighted_input;
    logic [window_size-1:0] sample_count;
    logic signed [DATA_WIDTH-1:0] avg_out;
    logic threshold_1_comb, threshold_2_comb;

    // Window-based accumulation parameters
    reg logic sum_ready_window = 0;
    reg [window_size-1:0] sample_count_reg = 0;

    // Threshold detection combinational logic
    threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1);
    threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2) || (sum_accum <= -THRESHOLD_VALUE_2);

    // Weighted input calculation
    weighted_input = data_in * WEIGHT;

    // Sequential logic for sum accumulation
    always_ff @(posedge clock) begin
        if (reset) begin
            sum_accum <= 0;
            sum_ready <= 0;
            sum_ready_window <= 0;
            weighted_input <= 0;
            sample_count_reg <= 0;
        end else begin
            if (ACCUM_MODE == 0) begin // Threshold-based continuous accumulation
                if (data_valid) begin
                    sum_accum <= sum_accum + weighted_input;
                    if (sum_accum >= THRESHOLD_VALUE_1 || sum_accum <= -THRESHOLD_VALUE_1) begin
                        threshold_1 <= 1;
                    end
                    if (sum_accum >= THRESHOLD_VALUE_2 || sum_accum <= -THRESHOLD_VALUE_2) begin
                        threshold_2 <= 1;
                    end
                    sum_ready <= 1;
                end
                // No output until threshold is met or sum_ready is asserted
            else if (ACCUM_MODE == 1) begin // Window-based accumulation with averaging
                if (data_valid) begin
                    sum_accum <= sum_accum + weighted_input;
                    sample_count_reg <= sample_count_reg + 1;
                    if (sample_count_reg >= window_size) begin
                        avg_out <= sum_accum / window_size;
                        sum_ready_window <= 1;
                        sum_accum <= 0;
                        sample_count_reg <= 0;
                    end
                end
                // No output until window is processed
            end
        end
    end

    // Output signals
    sum_out = sum_accum;
    sum_ready_window <= sum_ready_window;
    avg_out <= avg_out;
    threshold_1 <= threshold_1;
    threshold_2 <= threshold_2;
endmodule