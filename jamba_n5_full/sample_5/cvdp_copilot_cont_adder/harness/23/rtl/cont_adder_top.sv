module continuous_adder #(
    parameter DATA_WIDTH = 32,
    parameter THRESHOLD_VALUE_1 = 50,
    parameter THRESHOLD_VALUE_2 = 100,
    parameter SIGNED_INPUTS = 1,
    parameter WEIGHT = 1,
    parameter ACCUM_MODE = 0,
    parameter WINDOW_SIZE = 5,
    parameter [15:0] window_size_val = 5
) (
    input logic                          clk,        // Clock signal
    input logic                          reset,      // Reset signal, Active high and Synchronous
    input logic signed [DATA_WIDTH-1:0]  data_in,    // Signed or unsigned input data stream, parameterized width
    input logic                          data_valid, // Input data valid signal
    output logic signed [DATA_WIDTH-1:0] sum_out,    // Signed or unsigned output, parameterized width
    output logic                         sum_ready   // Signal to indicate sum is output and accumulator is reset
);

    localparam int MAX_SAMPLES = 1024;  // just for example, but we don't need to use it

    // Internal state
    reg [DATA_WIDTH-1:0] sum_accum;
    reg [DATA_WIDTH-1:0] weighted_input;
    reg [DATA_WIDTH-1:0] sum_out_temp;
    reg [DATA_WIDTH-1:0] avg_out;
    reg [DATA_WIDTH-1:0] threshold_1_comb;
    reg [DATA_WIDTH-1:0] threshold_2_comb;
    reg [DATA_WIDTH-1:0] sum_ready_reg;
    reg [DATA_WIDTH-1:0] sample_count;
    reg [15:0] window_samples;

    // Counters
    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum         <= {DATA_WIDTH{1'b0}};
            sum_ready         <= 1'b0;
            sum_out           <= {DATA_WIDTH{1'b0}};
            weighted_input    <= {DATA_WIDTH{1'b0}};
            sum_out_temp      <= 0;
            avg_out           <= 0;
            sample_count      <= 0;
            window_samples     <= 0;
        end else begin
            if (DATA_VALID) begin
                weighted_input <= weighted_input + data_in;
            end
        end
    end

    // Process accumulation
    always_ff @(posedge clk) begin
        if (ACCUM_MODE == 0) begin
            if (DATA_VALID) begin
                sum_accum <= sum_accum + weighted_input;

                // Check thresholds
                threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1);
                threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2) || (sum_accum <= -THRESHOLD_VALUE_2);

                sum_ready_reg = (THRESHOLD_VALUE_1_HIGH && threshold_1_comb) || (THRESHOLD_VALUE_2_HIGH && threshold_2_comb);
            end
        end else begin
            if (DATA_VALID) begin
                weighted_input <= weighted_input * WEIGHT;
            end
        end

        // Update outputs
        if (sum_ready_reg) begin
            sum_out         <= sum_accum;
            sum_ready        <= 1'b1;
        end else begin
            sum_out         <= 0;
            sum_ready        <= 1'b0;
        end

        if (ACCUM_MODE == 0) begin
            if (sum_ready_reg && threshold_1_comb) begin
                sum_out         <= sum_accum + data_in;
                sum_ready        <= 1'b1;
                sum_accum        <= {DATA_WIDTH{1'b0}};
            end
            else if (sum_ready_reg && threshold_2_comb) begin
                sum_out         <= sum_accum + data_in;
                sum_ready        <= 1'b1;
                sum_accum        <= {DATA_WIDTH{1'b0}};
            end
        end

        if (ACCUM_MODE == 1) begin
            if (sample_count == WINDOW_SIZE) begin
                avg_out         <= weighted_input / WINDOW_SIZE;
                sum_ready        <= 1'b1;
                sample_count     <= 0;
            end else begin
                avg_out         <= 0;
                sum_ready        <= 1'b0;
            end
        end
    end

endmodule
