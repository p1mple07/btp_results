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
    input logic signed [DATA_WIDTH-1:0] data_in,
    input logic window_size,
    output logic signed [DATA_WIDTH-1:0] sum_out,
    output logic sum_ready,
    output logic threshold_1,
    output logic threshold_2,
    output logic avg_out
);

    logic signed [DATA_WIDTH-1:0] sum_accum;
    logic [DATA_WIDTH-1:0] weighted_input;
    logic sample_count;
    logic window_valid;
    logic threshold_1_comb;
    logic threshold_2_comb;

    // Sequential logic for sum accumulation
    always_ff @(posedge clock) begin
        if (reset) begin
            sum_accum <= {DATA_WIDTH{1'b0}};
            sum_ready <= 1'b0;
            sum_out <= {DATA_WIDTH{1'b0}};
            window_valid <= 1'b0;
            sample_count <= 1'b0;
        end else begin
            if (data_valid) begin
                weighted_input <= data_in * WEIGHT;
                sum_accum <= sum_accum + weighted_input;

                if (ACCUM_MODE == 0) begin
                    if ((sum_accum + weighted_input >= THRESHOLD_VALUE_1) || (sum_accum + weighted_input <= -THRESHOLD_VALUE_1)) begin
                        threshold_1 <= 1;
                        threshold_2 <= 0;
                        sum_out <= sum_accum + weighted_input;
                        sum_ready <= 1'b1;
                        sum_accum <= {DATA_WIDTH{1'b0}};
                    end else begin
                        threshold_1 <= 0;
                        threshold_2 <= 0;
                        sum_ready <= 1'b0;
                    end
                end else if (ACCUM_MODE == 1) begin
                    sample_count <= sample_count + 1;
                    window_valid <= 1'b1;
                    
                    if (sample_count >= window_size) begin
                        avg_out <= sum_accum / window_size;
                        sum_ready <= 1'b1;
                        sum_out <= sum_accum;
                        sum_accum <= {DATA_WIDTH{1'b0}};
                        sample_count <= 1'b0;
                    end else begin
                        threshold_1 <= 0;
                        threshold_2 <= 0;
                        sum_ready <= 1'b0;
                    end
                end
            end
        end
    end

    // Threshold signal generation
    threshold_1_comb <= (sum_accum >= THRESHOLD_VALUE_1) ? 1'b1 : 1'b0;
    threshold_1_comb <= (sum_accum <= -THRESHOLD_VALUE_1) ? 1'b1 : 1'b0;
    threshold_2_comb <= (sum_accum >= THRESHOLD_VALUE_2) ? 1'b1 : 1'b0;
    threshold_2_comb <= (sum_accum <= -THRESHOLD_VALUE_2) ? 1'b1 : 1'b0;

    // Internal signal initialization
    sum_ready <= 1'b0;
    sum_out <= {DATA_WIDTH{1'b0}};
    sum_accum <= {DATA_WIDTH{1'b0}};
    sample_count <= 1'b0;
    window_valid <= 1'b0;
endmodule