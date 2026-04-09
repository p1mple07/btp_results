module Word_Change_Pulse#(
    parameter DATA_WIDTH = 8
) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire [DATA_WIDTH-1:0] mask,
    input  wire [DATA_WIDTH-1:0] match_pattern,
    input  wire                  enable,
    input  wire                  latch_pattern,
    output reg                   word_change_pulse,
    output reg                   pattern_match_pulse,
    output reg [DATA_WIDTH-1:0] latched_pattern
);

    wire [DATA_WIDTH-1:0] change_pulses;
    wire [DATA_WIDTH-1:0] masked_data_in;
    reg [DATA_WIDTH-1:0] masked_change_pulses;
    reg [DATA_WIDTH-1:0] latched_match_pattern;
    reg match_detected;

    genvar i;
    reg [DATA_WIDTH-1:0] prev_masked_data_in;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in <= {DATA_WIDTH{1'b0}};
            masked_change_pulses <= {DATA_WIDTH{1'b0}};
            word_change_pulse <= 1'b0;
            match_detected <= 1'b0;
            pattern_match_pulse <= 1'b0;
            latched_pattern <= {DATA_WIDTH{1'b0}};
            latched_match_pattern <= {DATA_WIDTH{1'b0}};
        end else if (enable) begin
            if (latch_pattern) begin
                latched_match_pattern <= match_pattern;
            end
            masked_data_in <= data_in & mask;
            // Instantiate Bit_Change_Detector modules
            for (i = 0; i < DATA_WIDTH; i++) begin
                Bit_Change_Detector#(i+1) bit_chd (
                    .clk(clk),
                    .reset(reset),
                    .bit_in(data_in[i]),
                    .mask(mask[i]),
                    .change_pulse(masked_change_pulses[i])
                );
            end
            // Collect change pulses
            change_pulses <= masked_change_pulses;
            // Check for any change
            if (change_pulses) begin
                match_detected <= 1;
            end
            // Check for pattern match
            if (match_detected && latched_match_pattern == masked_data_in) begin
                pattern_match_pulse <= 1;
            end
        end else begin
            // No operation when enable is low
        end
    end
endmodule

module Bit_Change_Detector (
    input  wire  clk,
    input  wire  reset,
    input  wire  bit_in,
    output reg  change_pulse
);

    reg bit_in_d;
    reg prev_bit;
    reg change;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_in_d <= 0;
            prev_bit <= 0;
            change <= 0;
        end else begin
            bit_in_d <= bit_in;
            prev_bit <= bit_in_d;
        end
    end

    always @(*) begin
        change <= (bit_in_d != prev_bit);
        change_pulse <= change;
    end
endmodule