module Word_Change_Pulse#(
    parameter DATA_WIDTH = 8
) (
    input  wire clk,
    input  wire reset,
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire [DATA_WIDTH-1:0] mask,
    input  wire [DATA_WIDTH-1:0] match_pattern,
    input  wire enable,
    input  wire latch_pattern,
    output reg word_change_pulse,
    output reg pattern_match_pulse,
    output reg [DATA_WIDTH-1:0] latched_pattern
);

    wire [DATA_WIDTH-1:0] change_pulses;

    reg [DATA_WIDTH-1:0] masked_data_in;
    reg [DATA_WIDTH-1:0] masked_change_pulses;
    reg match_detected;

    genvar i;

    // Instantiate Bit_Change_Detector modules
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            Bit_Change_Detector bcd_inst(.clk(clk), .reset(reset), .bit_in(data_in[i]), .change_pulse(masked_change_pulses[i]));
        end
    endgenerate

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in <= {DATA_WIDTH{1'b0}};
            masked_change_pulses <= {DATA_WIDTH{1'b0}};
            word_change_pulse <= 1'b0;
            pattern_match_pulse <= 1'b0;
            latched_pattern <= {DATA_WIDTH{1'b0}};
        end else if (enable) begin
            // Latch pattern if latch_pattern is asserted
            if (latch_pattern) begin
                latched_pattern <= match_pattern;
            end
            // Mask data_in, detect changes, and generate word_change_pulse
            masked_data_in <= data_in & mask;
            masked_change_pulses <= bcd_inst.change_pulse;
            // Generate word_change_pulse when any change is detected
            word_change_pulse <= (masked_change_pulses | ~masked_change_pulses) & ~(masked_data_in == data_in);
            // Compare masked data_in with latched_pattern & mask for pattern_match_pulse
            match_detected <= (masked_data_in == latched_pattern) & mask;
            pattern_match_pulse <= match_detected & enable;
        end else begin
            // Handle the case when 'enable' is low
            word_change_pulse <= 1'b0;
            pattern_match_pulse <= 1'b0;
        end
    end

endmodule


module Bit_Change_Detector (
    input  wire clk,
    input  wire reset,
    input  wire bit_in,
    output reg change_pulse
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
        change_pulse <= bit_in_d != bit_in;
    end
endmodule
