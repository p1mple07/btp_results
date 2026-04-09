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
    wire [DATA_WIDTH-1:0] masked_data_in;
    wire [DATA_WIDTH-1:0] masked_change_pulses;
    wire match_detected;

    genvar i;

    // Instantiate Bit_Change_Detector modules
    generate
        for (i = 0; i < DATA_WIDTH; i++) begin : bcd_gen
            Bit_Change_Detector bcd_inst(.clk(clk),
                                         .reset(reset),
                                         .bit_in(data_in[i]),
                                         .change_pulse(masked_change_pulses[i]));
        end
    endgenerate

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in <= {DATA_WIDTH{1'b0}};
            masked_change_pulses <= {DATA_WIDTH{1'b0}};
            word_change_pulse <= 1'b0;
            match_detected <= 1'b0;
            pattern_match_pulse <= 1'b0;
            latched_pattern <= {DATA_WIDTH{1'b0}};
        end else if (enable) begin
            // Latch pattern if latch_pattern is asserted
            if (latch_pattern) begin
                latched_pattern <= match_pattern;
            end
            // Mask data_in, detect changes, and generate word_change_pulse
            masked_data_in = {DATA_WIDTH{1'b0}} & data_in;
            masked_change_pulses = masked_data_in ^ masked_change_pulses;
            word_change_pulse = masked_change_pulses;
            // Compare masked data_in with latched_pattern & mask for pattern_match_pulse
            if (masked_data_in == latched_pattern) begin
                match_detected <= 1'b1;
                pattern_match_pulse <= 1'b1;
            end else begin
                match_detected <= 1'b0;
                pattern_match_pulse <= 1'b0;
            end
        end else begin
            // Handle the case when 'enable' is low
            word_change_pulse <= 1'b0;
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
            bit_in_d <= 1'b0;
        end else begin
            bit_in_d <= bit_in;
        end
    end

    always @(*) begin
        if (bit_in_d != bit_in) begin
            change_pulse <= 1'b1;
        end else begin
            change_pulse <= 1'b0;
        end
    end

endmodule
