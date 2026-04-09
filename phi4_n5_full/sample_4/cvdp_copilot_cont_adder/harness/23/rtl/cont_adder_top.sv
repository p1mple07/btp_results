module continuous_adder #(
    parameter DATA_WIDTH         = 32,       // Bit-width for data signals
    parameter THRESHOLD_VALUE_1  = 50,       // Lower threshold value (default: 50)
    parameter THRESHOLD_VALUE_2  = 100,      // Upper threshold value (default: 100)
    parameter SIGNED_INPUTS      = 1,        // 1 = signed arithmetic, 0 = unsigned arithmetic
    parameter ACCUM_MODE         = 0,        // 0 = Threshold-Based Continuous Accumulation, 1 = Window-Based Accumulation with Averaging
    parameter WEIGHT             = 1         // Multiplicative weight for input data (default: 1)
) (
    input  logic                      clk,
    input  logic                      reset,
    input  logic signed [DATA_WIDTH-1:0] data_in,
    input  logic                      data_valid,
    input  logic [15:0]               window_size,  // Used only in ACCUM_MODE = 1
    output logic signed [DATA_WIDTH-1:0] sum_out,
    output logic signed [DATA_WIDTH-1:0] avg_out,
    output logic                      threshold_1,
    output logic                      threshold_2,
    output logic                      sum_ready
);

    // Internal accumulator and sample counter
    logic signed [DATA_WIDTH-1:0] sum_accum;
    logic [15:0]                 sample_count;
    // Internal signal for weighted input
    logic signed [DATA_WIDTH-1:0] weighted_input;
    // Combinational signals for threshold detection
    logic                         threshold_1_comb;
    logic                         threshold_2_comb;

    // Sequential block for accumulation and output generation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear accumulator, sample counter and outputs
            sum_accum    <= {DATA_WIDTH{1'b0}};
            sample_count <= 16'd0;
            sum_out      <= {DATA_WIDTH{1'b0}};
            avg_out      <= {DATA_WIDTH{1'b0}};
            // threshold_1 and threshold_2 will be driven in combinational block
        end else begin
            if (data_valid) begin
                // Apply weighting to input data
                weighted_input = data_in * WEIGHT;
                
                if (ACCUM_MODE == 0) begin
                    // -------------------------------
                    // Threshold-Based Continuous Accumulation Mode
                    // -------------------------------
                    // Accumulate weighted input continuously
                    sum_accum <= sum_accum + weighted_input;
                    
                    // Determine threshold conditions based on signed/unsigned mode
                    if (SIGNED_INPUTS) begin
                        threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1) ||
                                            (sum_accum <= -THRESHOLD_VALUE_1);
                        threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2) ||
                                            (sum_accum <= -THRESHOLD_VALUE_2);
                    end else begin
                        threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1);
                        threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2);
                    end
                    
                    // When any threshold is crossed, output the current accumulated sum
                    if (threshold_1_comb || threshold_2_comb) begin
                        sum_out   <= sum_accum;
                        sum_ready <= 1'b1;
                    end else begin
                        // In continuous mode, sum_out is only updated when a threshold is crossed.
                        // Optionally, you could continuously drive sum_out with sum_accum.
                        sum_ready <= 1'b0;
                    end
                end else begin
                    // -------------------------------
                    // Window-Based Accumulation with Averaging Mode
                    // -------------------------------
                    // Accumulate weighted input and count samples
                    sum_accum    <= sum_accum + weighted_input;
                    sample_count <= sample_count + 1;
                    
                    // Determine threshold conditions
                    if (SIGNED_INPUTS) begin
                        threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1) ||
                                            (sum_accum <= -THRESHOLD_VALUE_1);
                        threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2) ||
                                            (sum_accum <= -THRESHOLD_VALUE_2);
                    end else begin
                        threshold_1_comb = (sum_accum >= THRESHOLD_VALUE_1);
                        threshold_2_comb = (sum_accum >= THRESHOLD_VALUE_2);
                    end
                    
                    // When the window is complete, output the accumulated sum and average
                    if (sample_count == window_size) begin
                        sum_out   <= sum_accum;
                        // Division: cast window_size to signed for proper arithmetic
                        avg_out   <= sum_accum / $signed(window_size);
                        sum_ready <= 1'b1;
                        // Reset accumulator and sample counter after window processing
                        sum_accum    <= {DATA_WIDTH{1'b0}};
                        sample_count <= 16'd0;
                    end else begin
                        // Before window completion, outputs remain at zero
                        sum_out   <= {DATA_WIDTH{1'b0}};
                        avg_out   <= {DATA_WIDTH{1'b0}};
                        sum_ready <= 1'b0;
                    end
                end
            end
            // If data_valid is not asserted, no updates occur.
        end
    end

    // Combinational assignment for threshold output signals
    always_comb begin
        threshold_1 = threshold_1_comb;
        threshold_2 = threshold_2_comb;
    end

endmodule