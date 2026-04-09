module Bit_Change_Detector (
   input  wire clk,          // Clock signal
    input  wire reset,       // Reset signal to initialize the module
    input  wire bit_in,      // Single bit input to detect changes
    output reg change_pulse // Pulse signal indicating a change in the input bit
);

   reg bit_in_d;

   always @(posedge clk or posedge reset) begin
        if (reset) begin
             // Initialize all internal registers to zero
             bit_in_d <= 1'b0;
             change_pulse <= 1'b0;
        end else begin
             // Update previous state
             bit_in_d <= bit_in;
             if (bit_in_d != bit_in) change_pulse = 1'b1;
         end
   end

endmodule

module Word_Change_Pulse#(parameter DATA_WIDTH = 8) (
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

    wire [DATA_WIDTH-1:0] masked_data_in;
    reg [DATA_WIDTH-1:0] masked_change_pulses;
    reg match_detected;

    genvar i;

    initial begin
        $display("Number of bits: %0d", DATA_WIDTH);
        for (int i = 0; i < DATA_WIDTH; i++) begin
            Bit_Change_Detector d(
                .clk(clk),
                .reset(reset),
                .bit_in(data_in[i]),
                .mask(mask[i]),
                .match_pattern(match_pattern),
                .enable(enable),
                .latch_pattern(latch_pattern),
                .change_pulse(masked_change_pulses[i])
            );
        end
    end

    assign word_change_pulse = any({$caret(masked_change_pulses)});

    assign pattern_match_pulse = latched_pattern == match_pattern;

    assign latched_pattern = data_in[0];

endmodule
