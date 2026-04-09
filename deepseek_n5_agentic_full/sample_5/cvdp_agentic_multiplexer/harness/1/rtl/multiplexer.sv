module multiplexer #( 
    parameter DATA_WIDTH = 8,
    parameter NUM_INPUTS = 4,
    parameter REGISTER_OUTPUT = 0,
    parameter HAS_DEFAULT = 0,
    parameter [DATA_WIDTH-1:0] DEFAULT_VALUE = {DATA_WIDTH{1'b0}}
) (
    input  wire clk,
    input  wire rst_n,
    input  wire [(DATA_WIDTH*NUM_INPUTS)-1:0] inp,
    input  wire [$clog2(NUM_INPUTS)-1:0]     sel,
    input  wire bypass,
    output reg [DATA_WIDTH-1:0] out
) 

{
    // Construct the input array from the flat input vector
    local param sel_size = tolnum($clog2(NUM_INPUTS));
    reg [DATA_WIDTH-1:0] inp_array[NUM_INPUTS];

    generate i from 0 to NUM_INPUTS-1
    #0
    inp_array[i] = inp[(i * DATA_WIDTH): (i * DATA_WIDTH)+DATA_WIDTH-1]
    endgenerate

    // Selection logic
    out = ?;
    if (HAS_DEFAULT == 1 && sel >= NUM_INPUTS)
        out = DEFAULT_VALUE;
    else if (bypass == 1)
        out = inp_array[0];
    else
        out = inp_array[sel];
}

#1
endmodule