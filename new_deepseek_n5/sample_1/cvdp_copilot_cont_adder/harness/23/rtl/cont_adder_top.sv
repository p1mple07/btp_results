module continuous_adder #(
    parameter  DATA_WIDTH = 32,
    parameter  THRESHOLD_VALUE_1 = 50,
    parameter  THRESHOLD_VALUE_2 = 100,
    parameter  SIGNED_INPUTS = 1,
    parameter  ACCUM_MODE = 0,
    parameter  WEIGHT = 1
) (
    input logic                          clk,
    input logic                          reset,
    input logic signed [DATA_WIDTH-1:0] data_in,
    input logic                          data_valid,
    output logic signed [DATA_WIDTH-1:0] sum_out,
    output logic                         sum_ready,
    output logic                          threshold_1,
    output logic                          threshold_2,
    output logic                         avg_out [DATA_WIDTH-1:0]
);

    logic signed [DATA_WIDTH-1:0] sum_accum;
    logic [DATA_WIDTH-1:0] weighted_input;
    logic [15:0] sample_count;
    logic signed [DATA_WIDTH-1:0] avg_out_reg;

    // Internal accumulator to store the running sum
    sum_accum = 0;

    // Accumulator for window-based averaging
    sum_accum = sum_accum + weighted_input;

    // Window-based accumulation and averaging
    if (ACCUM_MODE == 1) {
        if (data_valid) {
            sample_count = 0;
        }
    }

    // Threshold detection signals
    logic threshold_1_comb = (sum_accum + data_in >= THRESHOLD_VALUE_1) || (sum_accum + data_in <= -THRESHOLD_VALUE_1);
    logic threshold_2_comb = (sum_accum + data_in >= THRESHOLD_VALUE_2) || (sum_accum + data_in <= -THRESHOLD_VALUE_2);

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum <= {DATA_WIDTH{1'b0}};
            sum_ready <= 1'b0;
            sum_out <= {DATA_WIDTH{1'b0}};
        end
        else begin
            if (data_valid) begin
                if (ACCUM_MODE == 0) begin
                    if (sum_accum + data_in >= THRESHOLD_VALUE_1 || sum_accum + data_in <= -THRESHOLD_VALUE_1) begin
                        sum_out <= sum_accum + data_in;
                        threshold_1 <= 1'b1;
                        threshold_2 <= 1'b0;
                        sum_ready <= 1'b1;
                    end else begin
                        sum_ready <= 1'b0;
                    end
                    sum_accum <= sum_accum + data_in;
                end else begin
                    if (sample_count < window_size) begin
                        sample_count <= sample_count + 1;
                        sum_accum <= sum_accum + weighted_input;
                    end else begin
                        avg_out_reg <= sum_accum / window_size;
                        sum_ready <= 1'b1;
                        sum_out <= avg_out_reg;
                        sum_accum <= {DATA_WIDTH{1'b0}};
                        sample_count <= 0;
                    end
                end
            end
        end
    end

    // Output signals
    sum_out <= sum_accum;
    sum_ready <= sum_ready;
    threshold_1 <= threshold_1_comb;
    threshold_2 <= threshold_2_comb;
    avg_out <= avg_out_reg;