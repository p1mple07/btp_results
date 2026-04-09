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

    // Wires from Bit_Change_Detector instances
    wire [DATA_WIDTH-1:0] change_pulses;

    // Registers for masked signals
    reg [DATA_WIDTH-1:0] masked_data_in;
    reg [DATA_WIDTH-1:0] masked_change_pulses;

    // Instantiate Bit_Change_Detector for each bit of data_in
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : bit_det_inst
            Bit_Change_Detector u_bit_detector (
                .clk(clk),
                .reset(reset),
                .bit_in(data_in[i]),
                .change_pulse(change_pulses[i])
            );
        end
    endgenerate

    // Synchronous process: Latch pattern, mask inputs, detect changes, and generate pulses
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in         <= {DATA_WIDTH{1'b0}};
            masked_change_pulses   <= {DATA_WIDTH{1'b0}};
            word_change_pulse      <= 1'b0;
            pattern_match_pulse    <= 1'b0;
            latched_pattern        <= {DATA_WIDTH{1'b0}};
        end else if (enable) begin
            // Latch the current match_pattern when latch_pattern is asserted
            if (latch_pattern)
                latched_pattern <= match_pattern;
            
            // Apply mask to data_in and change pulses
            masked_data_in         <= data_in & mask;
            masked_change_pulses   <= mask & change_pulses;
            
            // Generate word-level change pulse if any masked bit has changed
            word_change_pulse      <= |masked_change_pulses;
            
            // Generate pattern match pulse if masked data equals (latched_pattern & mask)
            pattern_match_pulse    <= (masked_data_in == (latched_pattern & mask));
        end else begin
            // When module is disabled, clear the pulses
            word_change_pulse      <= 1'b0;
            pattern_match_pulse    <= 1'b0;
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

    // Register to store the previous bit value
    reg bit_in_d;

    // Synchronous process: update the stored bit value and generate a pulse on change
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_in_d     <= 1'b0;
            change_pulse <= 1'b0;
        end else begin
            bit_in_d <= bit_in;
        end
    end

    // Combinational process: compare current bit with previous value to generate a pulse
    always @(*) begin
        change_pulse = (bit_in != bit_in_d);
    end

endmodule