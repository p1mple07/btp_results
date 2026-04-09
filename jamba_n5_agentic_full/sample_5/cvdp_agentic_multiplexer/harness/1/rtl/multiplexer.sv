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
    input  wire [$clog2(NUM_INPUTS)-1:0]       sel,
    input  wire bypass,
    output reg  [DATA_WIDTH-1:0] out
);

reg [DATA_WIDTH-1:0] output_data;

always @(posedge clk) begin
    // Generate output data array
    generate
        case (sel)
            default:
                output_data = default_value;
        endcase
    endgenerate

    if (REGISTER_OUTPUT) begin
        assign out = output_data;
    end else {
        // combinational
        out = output_data;
    }
endalways

always @(*) begin
    out = output_data;
end

initial begin
    // testbench stuff
    // not needed
end

endmodule
