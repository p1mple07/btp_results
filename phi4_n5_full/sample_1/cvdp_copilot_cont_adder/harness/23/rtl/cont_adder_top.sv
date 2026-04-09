module continuous_adder #(
    parameter DATA_WIDTH         = 32,                  // Bit-width for data paths
    parameter SIGNED_INPUTS      = 1,                   // 1 = signed, 0 = unsigned operations
    parameter ACCUM_MODE         = 0,                   // 0: Threshold-Based Continuous, 1: Window-Based with Averaging
    parameter WEIGHT             = 1,                   // Multiplicative weight for each input
    parameter THRESHOLD_VALUE_1  = 50,                  // First threshold value (default: 50)
    parameter THRESHOLD_VALUE_2  = 100                  // Second threshold value (default: 100)
) (
    input  logic                        clk,                // Clock signal
    input  logic                        reset,              // Active-high synchronous reset
    input  logic signed [DATA_WIDTH-1:0] data_in,            // Input data stream (signed if SIGNED_INPUTS==1)
    input  logic                        data_valid,         // Data valid signal
    input  logic [15:0]                 window_size,        // Number of samples for window-based mode (ACCUM_MODE==1)
    output logic signed [DATA_WIDTH-1:0] sum_out,            // Accumulated sum output
    output logic                        sum_ready,          // Indicates that sum_out (and avg_out in mode 1) is valid
    output logic                        threshold_1,        // High when accumulated sum crosses THRESHOLD_VALUE_1 (either direction)
    output logic                        threshold_2,        // High when accumulated sum crosses THRESHOLD_VALUE_2 (either direction)
    output logic signed [DATA_WIDTH-1:0] avg_out             // Average output (valid only in ACCUM_MODE==1)
);

  //-------------------------------------------------------------------------
  // Compute the weighted input based on SIGNED_INPUTS parameter
  //-------------------------------------------------------------------------
  generate
    if (SIGNED_INPUTS) begin : gen_signed
      logic signed [DATA_WIDTH-1:0] weighted_input;
      always_comb begin
        weighted_input = data_in * WEIGHT;
      end
    end
    else begin : gen_unsigned
      logic [DATA_WIDTH-1:0] weighted_input;
      always_comb begin
        weighted_input = data_in * WEIGHT;
      end
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Internal Registers
  //-------------------------------------------------------------------------
  // Accumulated sum of weighted inputs
  logic signed [DATA_WIDTH-1:0] sum_accum;
  // Sample counter for window-based accumulation (ACCUM_MODE==1)
  logic [15:0] sample_count;
  // Registered ready and output signals to introduce 1-cycle latency in mode 0
  logic sum_ready_reg;
  logic signed [DATA_WIDTH-1:0] sum_out_reg;

  //-------------------------------------------------------------------------
  // Main Sequential Logic
  //-------------------------------------------------------------------------
  always_ff @(posedge clk) begin
    if (reset) begin
      sum_accum        <= '0;
      sample_count     <= 16'd0;
      sum_ready_reg    <= 1'b0;
      sum_out_reg      <= '0;
      avg_out          <= '0;
    end
    else if (data_valid) begin
      if (ACCUM_MODE == 0) begin
        //-------------------------------
        // Mode 0: Threshold-Based Continuous Accumulation
        //-------------------------------
        // Continuously accumulate the weighted input.
        sum_accum <= sum_accum + weighted_input;
        // Check if the accumulated sum crosses either threshold.
        if ( ((sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1)) ||
             ((sum_accum >= THRESHOLD_VALUE_2) || (sum_accum <= -THRESHOLD_VALUE_2)) ) begin
          // Set the registered output and ready signal.
          sum_ready_reg <= 1'b1;
          sum_out_reg   <= sum_accum;
        end
        else begin
          sum_ready_reg <= 1'b0;
        end
      end
      else begin
        //-------------------------------
        // Mode 1: Window-Based Accumulation with Averaging
        //-------------------------------
        if (sample_count < window_size) begin
          // Accumulate the weighted input and increment sample counter.
          sum_accum     <= sum_accum + weighted_input;
          sample_count  <= sample_count + 1;
          sum_ready_reg <= 1'b0;
          sum_out_reg   <= '0;
          avg_out       <= '0;
        end
        else begin
          // When the window is complete, output the accumulated sum and average.
          sum_out_reg   <= sum_accum;
          avg_out       <= sum_accum / window_size;  // Arithmetic division for average
          sum_ready_reg <= 1'b1;
          // Reset the accumulator and sample counter for the next window.
          sum_accum     <= '0;
          sample_count  <= 16'd0;
        end
      end
    end
  end

  //-------------------------------------------------------------------------
  // Combinational Output Assignments
  //-------------------------------------------------------------------------
  // Threshold signals remain high as long as the accumulated sum exceeds the threshold.
  assign threshold_1 = ((sum_accum >= THRESHOLD_VALUE_1) || (sum_accum <= -THRESHOLD_VALUE_1));
  assign threshold_2 = ((sum_accum >= THRESHOLD_VALUE_2) || (sum_accum <= -THRESHOLD_VALUE_2));

  // Drive registered ready and sum output signals (1-cycle latency in mode 0).
  assign sum_ready = sum_ready_reg;
  assign sum_out   = sum_out_reg;

endmodule