module multiplexer #( 
    parameter DATA_WIDTH = 8,
    parameter NUM_INPUTS = 3,
    parameter REGISTER_OUTPUT = 1,
    parameter HAS_DEFAULT = 1,
    parameter DEFAULT_VALUE = 8'h55
) (
    input wire clk,
    input wire rst_n,
    input wire [(DATA_WIDTH*NUM_INPUTS)-1:0] inp,
    input wire [$clog2(NUM_INPUTS)-1:0] sel,
    input wire bypass,
    output reg [DATA_WIDTH-1:0] out
);

// Unpack the sel signal into a scalar value
reg sel_val = sel;

// Number of bits required to represent the sel signal
integer num_sel_bits = $clog2(NUM_INPUTS);

// Convert the flat inp vector into an array of wires
wire [DATA_WIDTH:0] inp_array[NUM_INPUTS];
generate #i for (i = 0; i < NUM_INPUTS; i = i + 1) begin
    inp_array[i] = inp[(i << DATA_WIDTH)];
end

// Bypass configuration
if (bypass) begin
    out = inp[0];
    // Alternatively, out = inp_array[0];
end

// Default value configuration
else if (!HAS_DEFAULT && sel < 0 || sel >= NUM_INPUTS) begin
    out = DEFAULT_VALUE;
end

// Normal selection configuration
else out = inp_array[sel];

// Register output configuration
if (REGISTER_OUTPUT) begin
    // Output is registered on the next clock cycle
    wire out_reg;
    out clock glitched on posedge clock;
    always @posedge clock begin
        out_reg = out;
    end
    out <= out_reg;
end

endmodule