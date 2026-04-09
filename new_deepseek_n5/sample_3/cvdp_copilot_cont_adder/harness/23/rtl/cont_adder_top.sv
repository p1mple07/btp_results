module continuous_adder #(
    parameter DATA_WIDTH = 32,
    parameter THRESHOLD_VALUE_1 = 50,
    parameter THRESHOLD_VALUE_2 = 100,
    parameter SIGNED_INPUTS = 1,
    parameter ACCUM_MODE = 0,
    parameter WEIGHT = 1
) (
    input logic clock, 
    input logic reset, 
    input logic data_valid,
    input logic signed [DATA_WIDTH-1:0] data_in,
    input logic weight [DATA_WIDTH-1:0] weighted_input,
    output logic signed [DATA_WIDTH-1:0] sum_out,
    output logic signed [DATA_WIDTH-1:0] avg_out,
    output logic sum_ready,
    output logic threshold_1,
    output logic threshold_2
);

    logic signed [DATA_WIDTH-1:0] sum_accum;
    logic signed [DATA_WIDTH-1:0] sum_accum_prev;
    logic [DATA_WIDTH-1:0] internal_weighted_input;
    logic [DATA_WIDTH-1:0] internal_weighted_input_prev;
    logic window_count;
    logic [DATA_WIDTH-1:0] internal_sum;
    logic [DATA_WIDTH-1:0] internal_sum_prev;
    logic signed [DATA_WIDTH-1:0] threshold_1_comb;
    logic signed [DATA_WIDTH-1:0] threshold_2_comb;
    logic signed [DATA_WIDTH-1:0] sum Ready_comb;
    logic signed [DATA_WIDTH-1:0] sum_comb;

    // Sequential logic for sum accumulation
    always_ff @(posedge clock) begin
        if (reset) begin
            sum_accum <= {DATA_WIDTH{1'b0}};
            sum_ready <= 1'b0;
            sum_out <= {DATA_WIDTH{1'b0}};
            sum_comb <= {DATA_WIDTH{1'b0}};
        end
        else begin
            if (data_valid) begin
                if (ACCUM_MODE == 0) begin
                    if (sum_ready) begin
                        sum_comb <= sum_accum;
                        sum_out <= sum_comb;
                        sum_ready <= 1'b0;
                    end
                    sum_accum <= sum_accum + data_in;
                    sum_comb <= sum_accum;
                end else begin
                    if (ACCUM_MODE == 1) begin
                        if (window_count >= window_size) begin
                            sum_comb <= sum_accum;
                            avg_out <= sum_comb;
                            avg_out <= sum_comb;
                            sum_ready <= 1'b1;
                            sum_out <= sum_comb;
                            sum_accum <= {DATA_WIDTH{1'b0}};
                            window_count <= 0;
                        end
                        sum_accum <= sum_accum + data_in * WEIGHT;
                        internal_weighted_input <= data_in * WEIGHT;
                        internal_sum <= internal_sum_prev + internal_weighted_input;
                        internal_sum_prev <= internal_sum;
                        sum_comb <= internal_sum;
                    end
                end
            end
        end
    end

    // Threshold detection logic
    always_comb begin
        threshold_1_comb <= (sum_comb >= THRESHOLD_VALUE_1) || (sum_comb <= -THRESHOLD_VALUE_1);
        threshold_2_comb <= (sum_comb >= THRESHOLD_VALUE_2) || (sum_comb <= -THRESHOLD_VALUE_2);
    end

    // Output signals
    sum_out <= sum_comb;
    threshold_1 <= threshold_1_comb;
    threshold_2 <= threshold_2_comb;
    sum_ready <= sum_ready_comb;
endmodule