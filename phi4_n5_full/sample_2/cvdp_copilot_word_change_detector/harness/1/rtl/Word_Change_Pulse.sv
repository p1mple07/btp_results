module Word_Change_Pulse#(
    parameter DATA_WIDTH = 8 // Default word width
) (
    input  wire                  clk,               // Clock signal for synchronizing operations
    input  wire                  reset,             // Reset signal to initialize the module
    input  wire [DATA_WIDTH-1:0] data_in,           // Input data, width defined by parameter DATA_WIDTH
    input  wire [DATA_WIDTH-1:0] mask,              // Mask signal to enable/disable change detection for each bit
    input  wire [DATA_WIDTH-1:0] match_pattern,     // Pattern to match for generating the pulse
    input  wire                  enable,            // Enable signal to allow module operation
    input  wire                  latch_pattern,     // Signal to latch the match pattern
    output reg                   word_change_pulse, // Output signal indicating a change in any bit of data_in
    output reg                   pattern_match_pulse, // Output signal indicating a match with the pattern
    output reg [DATA_WIDTH-1:0]  latched_pattern    // Latched pattern for comparison
);

    wire [DATA_WIDTH-1:0] change_pulses;

    reg [DATA_WIDTH-1:0] masked_data_in;
    reg [DATA_WIDTH-1:0] masked_change_pulses;

    // Registers used to generate one-cycle pulses
    reg word_prev;
    reg pattern_prev;

    // Instantiate Bit_Change_Detector modules for each bit
    genvar i;
    generate
       for(i = 0; i < DATA_WIDTH; i = i + 1) begin : bit_detectors
          Bit_Change_Detector bit_detector_inst (
             .clk(clk),
             .reset(reset),
             .bit_in(data_in[i]),
             .change_pulse(change_pulses[i])
          );
       end
    endgenerate

    // Main synchronous process
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in          <= {DATA_WIDTH{1'b0}};
            masked_change_pulses    <= {DATA_WIDTH{1'b0}};
            word_change_pulse       <= 1'b0;
            pattern_match_pulse     <= 1'b0;
            latched_pattern         <= {DATA_WIDTH{1'b0}};
            word_prev               <= 1'b0;
            pattern_prev            <= 1'b0;
        end else if (enable) begin
            // Latch the current match pattern if latch_pattern is asserted
            if (latch_pattern)
                latched_pattern <= match_pattern;

            // Apply the mask to data_in and the change pulses
            masked_data_in          <= data_in & mask;
            masked_change_pulses    <= change_pulses & mask;

            // Generate a one-cycle pulse for word_change_pulse when any masked bit changes.
            // The pulse is generated on the rising edge of the condition.
            if ((|masked_change_pulses) && (!word_prev))
                word_change_pulse <= 1'b1;
            else
                word_change_pulse <= 1'b0;
            word_prev <= (|masked_change_pulses);

            // Generate a one-cycle pulse for pattern_match_pulse when the masked data matches
            // the latched pattern (only on the rising edge of the match condition).
            if ((masked_data_in == (latched_pattern & mask)) && (!pattern_prev))
                pattern_match_pulse <= 1'b1;
            else
                pattern_match_pulse <= 1'b0;
            pattern_prev <= (masked_data_in == (latched_pattern & mask));
        end else begin
            // When enable is low, clear the pulses and internal flags.
            word_change_pulse <= 1'b0;
            pattern_match_pulse <= 1'b0;
            word_prev <= 1'b0;
            pattern_prev <= 1'b0;
        end
    end
   
endmodule


// Bit_Change_Detector Module
module Bit_Change_Detector (
   input  wire clk,          // Clock signal
   input  wire reset,        // Reset signal to initialize the module
   input  wire bit_in,       // Single bit input to detect changes
   output reg  change_pulse  // Pulse signal indicating a change in the input bit
);

    reg bit_in_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_in_d      <= 1'b0;
            change_pulse  <= 1'b0;
        end else begin
            // If the current bit differs from the previous value, assert the pulse.
            if (bit_in !== bit_in_d)
                change_pulse <= 1'b1;
            else
                change_pulse <= 1'b0;
            // Update the stored previous bit value.
            bit_in_d <= bit_in;
        end
    end
  
endmodule