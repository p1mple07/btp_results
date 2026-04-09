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
    reg                  match_detected;

    genvar i;

    // Instantiate Bit_Change_Detector modules for each bit
    foreach (i #0 to DATA_WIDTH-1) begin
        Bit_Change_Detector#1 (bcd_i (.clk(clk), .reset(reset), .bit_in(data_in[i]), .change_pulse(change_pulse_i)));
    end

    // Generate masked data
    masked_data_in = data_in & mask;

    // Aggregate change pulses
    masked_change_pulses = {change_pulse_0, change_pulse_1, change_pulse_2, change_pulse_3, change_pulse_4, change_pulse_5, change_pulse_6, change_pulse_7};

    // Word change pulse after one clock cycle
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in <= {DATA_WIDTH{1'b0}};
            masked_change_pulses <= {DATA_WIDTH{1'b0}};
            word_change_pulse <= 1'b0;
            match_detected <= 1'b0;
            pattern_match_pulse <= 1'b0;
            latched_pattern <= {DATA_WIDTH{1'b0}};
        elsif (enable) begin
            if (latch_pattern) begin
                latched_pattern_reg <= masked_data_in;
            end
            // Word change pulse is set after one clock cycle
            word_change_pulse <= 0;
            // Match pulse is set when pattern matches
            if (masked_data_in == latched_pattern_reg) begin
                pattern_match_pulse <= 1;
            end else begin
                pattern_match_pulse <= 0;
            end
            // After one clock cycle, set word_change_pulse
            word_change_pulse <= 1;
        else begin
            // Reset all states when enable is low
            masked_data_in <= {DATA_WIDTH{1'b0}};
            masked_change_pulses <= {DATA_WIDTH{1'b0}};
            word_change_pulse <= 1'b0;
            match_detected <= 1'b0;
            pattern_match_pulse <= 1'b0;
            latched_pattern_reg <= {DATA_WIDTH{1'b0}};
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
            bit_in_d <= 0;
            change_pulse <= 0;
        end else begin
            bit_in_d <= bit_in;
            // Compare previous bit value with current
            if (bit_in_d != bit_in) begin
                change_pulse <= 1;
            end
        end
    end

    always @(*) begin
        // Change pulse is set on the next clock cycle
        change_pulse <= change_pulse;
    end
endmodule