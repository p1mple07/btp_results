module Word_Change_Pulse#(
    parameter DATA_WIDTH = 8 // Default word width
) (
    input  wire                  clk,               // Clock signal for synchronizing operations
    input  wire                  reset,             // Reset signal to initialize the module
    input  wire [DATA_WIDTH-1:0] data_in,           // Input data, width defined by parameter DATA_WIDTH
    input  wire [DATA_WIDTH-1:0] mask,              // Mask signal to enable/disable change detection per bit (1 = detect changes, 0 = ignore changes)
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

    reg [DATA_WIDTH-1:0] latched_pattern;

    genvar i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in <= {DATA_WIDTH{1'b0}};
            masked_change_pulses <= {DATA_WIDTH{1'b0}};
            word_change_pulse <= 1'b0;
            match_detected <= 1'b0;
            pattern_match_pulse <= 1'b0;
            latched_pattern <= {DATA_WIDTH{1'b0}};
        end else if (enable) begin
            // Mask the data input
            masked_data_in = data_in[DATA_WIDTH-1:0];
            masked_data_in = masked_data_in & ~({DATA_WIDTH{1'b0}:mask);
            // Detect any change in the masked data
            assign word_change_pulse = any(masked_data_in);
            // Compare the masked data with the latched pattern
            assign pattern_match_pulse = latched_pattern == masked_data_in;
        end else begin
            // Handle low enable state
        end
    end

endmodule

module Bit_Change_Detector (
    input  wire clk,          // Clock signal
    input  wire reset,       // Reset signal to initialize the module
    input  wire bit_in,      // Single bit input to detect changes
    output reg change_pulse // Pulse signal indicating a change in the input bit
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
        change_pulse = bit_in_d;
    end

endmodule
