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
    output reg [DATA_WIDTH-1:0]  latched_pattern
);

    wire [DATA_WIDTH-1:0] change_pulses;

    reg [DATA_WIDTH-1:0] masked_data_in;
    reg [DATA_WIDTH-1:0] masked_change_pulses;
    reg                  match_detected;

    genvar i;

    module Bit_Change_Detector (
        input  wire clk,
        input  wire reset,
        input  wire bit_in,
        output reg change_pulse
    );

        reg bit_in_d;

        always @(posedge clk or posedge reset) begin
            if (reset) begin
                bit_in_d <= 0;
                change_pulse <= 0;
            end else begin
                bit_in_d <= bit_in;
                change_pulse <= 0;
            end
        end

        always @(*) begin
            if (change_pulse) begin
                change_pulse <= 0;
                bit_in_d <= bit_in;
            end
        end
    endmodule

    // Instantiate Bit_Change_Detector modules
    Bit_Change_Detector bit_detector`(.clk(clk), .reset(reset), .bit_in(data_in[i]), .change_pulse(change_pulses[i]));
    for (i = 0; i < DATA_WIDTH; i++) {
        $ Instantiate(bit_detector, (i));
    }

    // Process changes
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in <= 0;
            masked_change_pulses <= 0;
            word_change_pulse <= 0;
            match_detected <= 0;
            latched_pattern <= 0;
        end else if (enable) begin
            if (latch_pattern) begin
                latched_pattern <= masked_data_in;
            end
            masked_data_in <= data_in & mask;
            masked_change_pulses <= masked_data_in ^ bit_detector#i.bit_in_d;
            match_detected = masked_data_in == latched_pattern;
            if (match_detected) begin
                pattern_match_pulse <= 1;
            end
            if (masked_change_pulses) begin
                word_change_pulse <= 1;
            end
        end else begin
            masked_data_in <= 0;
            masked_change_pulses <= 0;
            word_change_pulse <= 0;
            match_detected <= 0;
            latched_pattern <= 0;
        end
    end
endmodule