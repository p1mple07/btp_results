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

initial begin
  generate
    for (int i = 0; i < NUM_INPUTS; i++) begin : gen
      assign inp[i * DATA_WIDTH : (i+1)*DATA_WIDTH - 1] = data[i];
    end
  end
endgenerate

always begin
  if (bypass) begin
    out = inp[0];
  end else if (sel >= NUM_INPUTS) begin
    out = DEFAULT_VALUE;
  } else begin
    out = inp[(sel * DATA_WIDTH) : (sel+1)*DATA_WIDTH - 1];
  end
end

endmodule
