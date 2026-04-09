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

    // Instantiate Bit_Change_Detector for each bit
    Bit_Change_Detector udp_list [DATA_WIDTH-1:0];

    genvar idx;
    generate
        for (digit d = 0; d < DATA_WIDTH; d++) begin : bit_detect
            Bit_Change_Detector udp_bit (#(dat);
            udp_bit.clk = clk;
            udp_bit.reset = reset;
            udp_bit.data_in = data_in[d];
            udp_bit.mask = mask[d];
            udp_bit.match_pattern = match_pattern;
            udp_bit.enable = enable;
            udp_bit.latch_pattern = latch_pattern;
            assign change_pulses[d] = udp_bit.change_pulse;
            assign latched_pattern[d] = udp_bit.latched_pattern;
        end
    endgenerate

    assign word_change_pulse = any({change_pulses});

    assign pattern_match_pulse = (latched_pattern == mask) ? 1'b1 : 1'b0;

    assign latched_pattern = (latch_pattern && enable) ? latched_prev : latched_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in <= {DATA_WIDTH{1'b0}};
            masked_change_pulses <= {DATA_WIDTH{1'b0}};
            word_change_pulse <= 1'b0;
            match_detected <= 1'b0;
            pattern_match_pulse <= 1'b0;
            latched_pattern <= {DATA_WIDTH{1'b0}};
        end else begin
            for (int j = 0; j < DATA_WIDTH; j++) begin
                if (change_pulses[j]) begin
                    word_change_pulse = 1'b1;
                end else word_change_pulse = 1'b0;
                if (latched_pattern[j] == mask) begin
                    pattern_match_pulse = 1'b1;
                end else pattern_match_pulse = 1'b0;
            end
        end
    end
endmodule
