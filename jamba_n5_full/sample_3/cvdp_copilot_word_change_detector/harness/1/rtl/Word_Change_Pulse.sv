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

    wire [DATA_WIDTH-1:0] masked_data_in;
    reg [DATA_WIDTH-1:0] masked_change_pulses;
    reg match_detected;

    genvar i;

    // Use a single Bit_Change_Detector to detect changes across all data_in bits
    Bit_Change_Detector bit_change_detector (.clk(clk), .reset(reset), .bit_in(data_in), .mask(mask), .change_pulse(word_change_pulse), .latched_pattern(latched_pattern));

    // Generate word_change_pulse when any masked bit changes
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in <= {DATA_WIDTH{1'b0}};
            word_change_pulse <= 1'b0;
            pattern_match_pulse <= 1'b0;
            latched_pattern <= {DATA_WIDTH{1'b0}};
        end else if (enable) begin
            if (latch_pattern) begin
                latched_pattern <= data_in;
            end else begin
                latched_pattern <= latched_pattern;
            end
        end else begin
            // No change detection when enable is low
        end
    end

    // Trigger word_change_pulse when a new change is detected
    always @(posedge clk) begin
        if (masked_change_pulses) begin
            word_change_pulse = 1'b1;
        end else begin
            word_change_pulse = 1'b0;
        end
    end

    // Pattern matching pulse
    always @(*) begin
        if (latched_pattern == data_in[0]) begin
            pattern_match_pulse <= 1'b1;
        end else begin
            pattern_match_pulse <= 1'b0;
        end
    end

endmodule

// Bit_Change_Detector Module
module Bit_Change_Detector (
    input  wire clk,          // Clock signal
    input  wire reset,       // Reset signal to initialize the module
    input  wire bit_in,      // Single bit input to detect changes
    output reg  change_pulse // Pulse signal indicating a change in the input bit
);

    reg bit_in_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize state
        end else begin
            // Update previous state
        end
    end

    always @(*) begin
        change_pulse = bit_in_d;
    end
endmodule
