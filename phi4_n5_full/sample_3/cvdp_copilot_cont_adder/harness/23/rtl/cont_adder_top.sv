module continuous_adder #(
    parameter DATA_WIDTH          = 32,       // Bit-width for data and accumulator
    parameter THRESHOLD_VALUE_1   = 50,       // First threshold value (default: 50)
    parameter THRESHOLD_VALUE_2   = 100,      // Second threshold value (default: 100)
    parameter SIGNED_INPUTS       = 1,        // 1 = signed arithmetic; 0 = unsigned arithmetic
    parameter ACCUM_MODE          = 0,        // 0 = Threshold-Based Continuous Accumulation; 1 = Window-Based Accumulation with Averaging
    parameter WEIGHT              = 1         // Multiplicative weight for input data
) (
    input  logic                        clk,
    input  logic                        reset,
    // Data input; always declared as signed to support both modes (for unsigned mode, arithmetic is interpreted accordingly)
    input  logic signed [DATA_WIDTH-1:0] data_in,
    input  logic                        data_valid,
    // window_size is used only in ACCUM_MODE = 1 (Window-Based Mode)
    input  logic [15:0]                 window_size,
    output logic signed [DATA_WIDTH-1:0] sum_out,
    output logic signed [DATA_WIDTH-1:0] avg_out,
    output logic                        threshold_1,
    output logic                        threshold_2,
    output logic                        sum_ready
);

    // Internal signals
    logic signed [DATA_WIDTH-1:0] sum_accum;       // Accumulator for weighted inputs
    logic signed [DATA_WIDTH-1:0] weighted_input;   // Weighted input value
    logic [15:0] sample_count;                      // Counts samples in window-based mode
    logic sum_ready_reg;                            // Registered signal for sum_ready (1-cycle latency in threshold mode)
    logic signed [DATA_WIDTH-1:0] sum_out_reg;      // Registered sum output (for 1-cycle latency)
    logic threshold_1_comb;                         // Combinational signal for threshold 1 detection
    logic threshold_2_comb;                         // Combinational signal for threshold 2 detection

    // Main sequential process
    always_ff @(posedge clk) begin
        if (reset) begin
            sum_accum      <= '0;
            sample_count   <= '0;
            sum_ready_reg  <= 1'b0;
            sum_out_reg    <= '0;
            avg_out        <= '0;
        end
        else begin
            if (data_valid) begin
                // Apply weighting to the input data
                weighted_input = data_in * WEIGHT;

                if (ACCUM_MODE == 0) begin  // Threshold-Based Continuous Accumulation Mode
                    // Continuously accumulate the weighted input
                    sum_accum <= sum_accum + weighted_input;

                    // Compute threshold signals based on the current accumulator value.
                    // For signed mode, check both positive and negative thresholds.
                    if (SIGNED_INPUTS) begin
                        threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1);
                        threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2) || (sum_accum <= -THRESHOLD_VALUE_2);
                    end
                    else begin
                        // In unsigned mode, only a positive threshold is meaningful.
                        threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1);
                        threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2);
                    end

                    // If any threshold is crossed, update the registered outputs.
                    // Note: The outputs have a 1-cycle latency.
                    if (threshold_1_comb || threshold_2_comb) begin
                        sum_out_reg    <= sum_accum;
                        sum_ready_reg  <= 1'b1;
                    end
                    else begin
                        // No threshold crossing: clear the registered outputs.
                        sum_out_reg    <= '0;
                        sum_ready_reg  <= 1'b0;
                    end
                    // In threshold mode, avg_out is not used.
                    avg_out <= '0;
                end
                else begin  // ACCUM_MODE == 1, Window-Based Accumulation with Averaging Mode
                    // Accumulate the weighted input over the window.
                    sum_accum <= sum_accum + weighted_input;
                    sample_count <= sample_count + 1;

                    // Compute threshold signals continuously.
                    if (SIGNED_INPUTS) begin
                        threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1);
                        threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2) || (sum_accum <= -THRESHOLD_VALUE_2);
                    end
                    else begin
                        threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1);
                        threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2);
                    end

                    // When the number of valid samples reaches window_size:
                    if (sample_count == window_size) begin
                        sum_out_reg <= sum_accum;
                        // Calculate the average over the window.
                        avg_out <= sum_accum / window_size;
                        sum_ready_reg <= 1'b1;
                        // Reset the accumulator and sample counter for the next window.
                        sum_accum <= '0;
                        sample_count <= '0;
                    end
                    else begin
                        // Before reaching the window size, outputs remain 0.
                        sum_out_reg <= '0;
                        avg_out <= '0;
                        sum_ready_reg <= 1'b0;
                    end
                end
            end
            // If data_valid is not asserted, the outputs remain unchanged.
        end
    end

    // Continuous assignments for outputs
    assign sum_out    = sum_out_reg;
    assign sum_ready  = sum_ready_reg;
    assign threshold_1 = threshold_1_comb;
    assign threshold_2 = threshold_2_comb;

endmodule