module Word_Change_Pulse#(
    parameter DATA_WIDTH = 8 // Default word width
) (
    input  wire                  clk,               // Clock signal for synchronizing operations
    input  wire                  reset,             // Reset signal to initialize the module
    input  wire [DATA_WIDTH-1:0] data_in,           // Input data word
    input  wire [DATA_WIDTH-1:0] mask,              // Mask signal to enable/disable change detection per bit
    input  wire [DATA_WIDTH-1:0] match_pattern,     // Pattern to match for generating the pulse
    input  wire                  enable,            // Enable signal for module operation
    input  wire                  latch_pattern,     // Signal to latch the current match pattern
    output reg                   word_change_pulse, // Pulse indicating a change in any masked bit of data_in (asserted one clock cycle after detection)
    output reg                   pattern_match_pulse, // Pulse indicating that the masked data_in matches the latched pattern
    output reg [DATA_WIDTH-1:0]  latched_pattern    // Register holding the latched pattern for comparison
);

    // Wires from Bit_Change_Detector instances
    wire [DATA_WIDTH-1:0] change_pulses;

    // Registers for internal processing
    reg [DATA_WIDTH-1:0] masked_data_in;
    reg [DATA_WIDTH-1:0] masked_change_pulses;
    reg                  prev_masked_change; // Used to delay the change pulse by one clock cycle

    genvar i;
    generate
       for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_bit_detectors
           Bit_Change_Detector u_bit_detector (
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
            masked_data_in         <= {DATA_WIDTH{1'b0}};
            masked_change_pulses   <= {DATA_WIDTH{1'b0}};
            prev_masked_change     <= 1'b0;
            word_change_pulse      <= 1'b0;
            pattern_match_pulse    <= 1'b0;
            latched_pattern        <= {DATA_WIDTH{1'b0}};
        end else if (enable) begin
            // Latch the current match pattern when latch_pattern is asserted
            if (latch_pattern)
                latched_pattern <= match_pattern;

            // Apply the mask to data_in for both change detection and pattern matching
            masked_data_in <= data_in & mask;
            // Mask the change pulses from each Bit_Change_Detector
            masked_change_pulses <= change_pulses & mask;

            // Store the OR of the masked change pulses to generate a delayed pulse
            prev_masked_change <= |masked_change_pulses;
            word_change_pulse  <= prev_masked_change;

            // Compare the masked data with the latched pattern (also masked)
            if (masked_data_in == (latched_pattern & mask))
                pattern_match_pulse <= 1;
            else
                pattern_match_pulse <= 0;
        end else begin
            // When enable is low, clear the outputs and internal flags
            prev_masked_change     <= 1'b0;
            word_change_pulse      <= 1'b0;
            pattern_match_pulse    <= 1'b0;
        end
    end

endmodule


// Bit_Change_Detector Module
module Bit_Change_Detector (
   input  wire clk,          // Clock signal
   input  wire reset,       // Reset signal to initialize the module
   input  wire bit_in,      // Single-bit input to detect changes
   output reg  change_pulse // Pulse signal indicating a change in the input bit
);

    // Register to hold the previous value of bit_in
    reg bit_in_d;

    // Synchronous update of the stored bit value
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_in_d <= 1'b0;
        end else begin
            bit_in_d <= bit_in;
        end
    end

    // Combinational logic to generate a pulse when the current bit differs from the previous bit
    always @(*) begin
        change_pulse = (bit_in !== bit_in_d);
    end

endmodule