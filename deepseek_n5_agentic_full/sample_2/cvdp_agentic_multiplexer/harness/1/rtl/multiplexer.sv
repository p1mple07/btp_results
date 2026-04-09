module multiplexer #( 
    parameter DATA_WIDTH = 8,
    parameter NUM_INPUTS = 4,
    parameter REGISTER_OUTPUT = 0,
    parameter HAS_DEFAULT = 0,
    parameter [DATA_WIDTH-1:0] DEFAULT_VALUE = {DATA_WIDTH{1'b0}}
)(
    input  wire [((NUM_INPUTS * DATA_WIDTH)+NUM_INPUTS-1):0] inp,
    input  wire [$clog2(NUM_INPUTS)-1:0]       sel,
    input  wire [1:0]                         bypass,
    input  wire [1:0]                         rst_n,
    input  wire [((NUM_INPUTS * DATA_WIDTH)-1):0] sel_vec,
    output reg [DATA_WIDTH-1:0]             out
);
    
    // Construct input array
    wire [((NUM_INPUTS * DATA_WIDTH)-1):0] inp_array;
    generate
        local param i = 0;
        do until(i == ((NUM_INPUTS * DATA_WIDTH)-1))
            inp_array[i] = inp[(i / DATA_WIDTH)][i % DATA_WIDTH];
            i = i + 1;
        end
    endgenerate
    
    // Selection logic
    if (HAS_DEFAULT == 1 && sel > (log2(NUM_INPUTS) - 1)) begin
        out = DEFAULT_VALUE;
    elsif (bypass == 1) begin
        out = inp_array[0];
    else begin
        out = inp_array[sel];
    end
endmodule