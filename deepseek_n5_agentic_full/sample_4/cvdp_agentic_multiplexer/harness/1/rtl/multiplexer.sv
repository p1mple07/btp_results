module multiplexer #( 
    parameter DATA_WIDTH = 8,
    parameter NUM_INPUTS = 4,
    parameter REGISTER_OUTPUT = 0,
    parameter HAS_DEFAULT = 0,
    parameter [DATA_WIDTH-1:0] DEFAULT_VALUE = {DATA_WIDTH{1'b0}}
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [(DATA_WIDTH*NUM_INPUTS)-1:0] inp,
    input  wire [$clog2(NUM_INPUTS)-1:0] sel,
    input  wire bypass,
    output reg  [DATA_WIDTH-1:0] out
);

// Convert flat input vector to array for easier access
reg [DATA_WIDTH-1:0] inp_array[NUM_INPUTS];
integer i;
always begin
    for (i = 0; i < NUM_INPUTS; i = i + 1) begin
        inp_array[i] = inp[i * DATA_WIDTH];
    end
end

// Selection logic
if (bypass) begin
    out = inp_array[0];
else begin
    case (sel)
        // Check if sel is out of range
        when ({-(1)}) // sel < 0
            out = DEFAULT_VALUE;
        when (>(num_inputs - 1)) // sel >= num_inputs
            out = DEFAULT_VALUE;
        default
            out = inp_array[sel];
    endcase
end

// Register output if requested
if (REGISTER_OUTPUT) begin
    out = out + 1'delay;
end

endmodule