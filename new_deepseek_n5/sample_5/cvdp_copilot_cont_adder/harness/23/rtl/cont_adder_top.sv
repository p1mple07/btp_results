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
    output logic                         threshold_1,
    output logic                         threshold_2,
    input logic unsigned [7:0] window_size,
    input logic                          sum_ready_reg,
    input logic                          avg_out
);

    logic signed [DATA_WIDTH-1:0] sum_accum;
    logic signed [DATA_WIDTH-1:0] weighted_input;
    logic [15:0] sample_count;
    logic threshold_1_comb, threshold_2_comb;

    // Window-based accumulation parameters
    reg unsigned [7:0] window_size_reg;

    // Accumulator for window-based averaging
    reg signed [DATA_WIDTH-1:0] sum_window;
    reg logic avg_valid;

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum <= {DATA_WIDTH{1'b0}};
            sum_ready_reg <= 1'b0;
            sum_out <= {DATA_WIDTH{1'b0}};
            threshold_1 <= 1'b0;
            threshold_2 <= 1'b0;
            sum_ready <= 1'b0;
            avg_out <= {DATA_WIDTH{1'b0}};
        end
        else begin
            if (data_valid) begin
                weighted_input = data_in * WEIGHT;
                sum_window <= sum_window + weighted_input;
                
                // Window-based accumulation logic
                if (ACCUM_MODE == 1) begin
                    sum_ready_reg <= 1'b0;
                    sample_count <= sample_count + 1;
                    
                    if (sample_count >= window_size_reg) begin
                        sum_out <= sum_window;
                        avg_out <= sum_window / window_size_reg;
                        sum_ready <= 1'b1;
                        sum_ready_reg <= 1'b1;
                        sum_window <= {DATA_WIDTH{1'b0}};
                        avg_out <= {DATA_WIDTH{1'b0}};
                    end
                    else begin
                        sum_ready <= 1'b0;
                    end
                end else begin
                    // Threshold-based accumulation logic
                    sum_accum <= sum_accum + weighted_input;
                    
                    if (sum_accum >= THRESHOLD_VALUE_1 or sum_accum <= -THRESHOLD_VALUE_1) begin
                        threshold_1 <= 1'b1;
                        threshold_2 <= 1'b0;
                        sum_ready <= 1'b1;
                    end else if (sum_accum >= THRESHOLD_VALUE_2 or sum_accum <= -THRESHOLD_VALUE_2) begin
                        threshold_1 <= 1'b0;
                        threshold_2 <= 1'b1;
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

    // Update window size
    always @(posedge clk) begin
        window_size_reg <= window_size;
    end

    // Threshold combinational logic
    always comb begin
        threshold_1_comb <= (sum_accum >= THRESHOLD_VALUE_1 or sum_accum <= -THRESHOLD_VALUE_1);
        threshold_2_comb <= (sum_accum >= THRESHOLD_VALUE_2 or sum_accum <= -THRESHOLD_VALUE_2);
    end

    // Signal assignments for sum readiness
    assign sum_ready = sum_ready_reg;