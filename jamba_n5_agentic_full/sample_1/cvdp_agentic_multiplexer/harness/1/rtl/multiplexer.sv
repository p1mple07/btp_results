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

always @(posedge clk) begin
    if (bypass) begin
        out = inp[0];
    end else begin
        if (HAS_DEFAULT && sel >= NUM_INPUTS) begin
            out = DEFAULT_VALUE;
        } else begin
            out = inp[(sel * DATA_WIDTH)];
        end
    end
end

endmodule
