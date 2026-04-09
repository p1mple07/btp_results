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
    for (i = 0; i < DATA_WIDTH; i++) begin : bcd
        Bit_Change_Detector uut (
            .clk(clk),
            .reset(reset),
            .bit_in(data_in[i]),
            .mask(mask[i]),
            .match_pattern(match_pattern),
            .enable(enable),
            .latch_pattern(latch_pattern),
            .change_pulse(bit_change_pulse_i)
        );
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            masked_data_in <= {DATA_WIDTH{1'b0}};
            masked_change_pulses <= {DATA_WIDTH{1'b0}};
            word_change_pulse <= 1'b0;
            match_detected <= 1'b0;
            pattern_match_pulse <= 1'b0;
            latched_pattern <= {DATA_WIDTH{1'b0}};
        end else if (enable) begin
            always @(posedge clk) begin
                // Mask the data_in and compare with masked_change_pulses
                masked_data_in = {DATA_WIDTH{1'b0}} ? data_in : {DATA_WIDTH{1'b0}};
                for (int j = 0; j < DATA_WIDTH; j++) begin
                    if (masked_data_in[j] != masked_change_pulses[j]) begin
                        word_change_pulse = 1'b1;
                    end else begin
                        word_change_pulse = 1'b0;
                    end
                }
            end
        end else begin
            word_change_pulse = 1'b0;
        end
    end

    always @(*) begin
        pattern_match_pulse <= (latched_pattern == {DATA_WIDTH{1'b0}} ? match_pattern : 1'b0);
    end

    assign latched_pattern = {DATA_WIDTH{1'b0}} ? data_in : {DATA_WIDTH{1'b0}};

endmodule
