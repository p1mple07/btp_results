module sync_muller_c_element #(
  parameter NUM_INPUT  = 2, // Number of input signals
  parameter PIPE_DEPTH = 1  // Number of pipeline stages
) (
  input  logic                  clk   , // Clock signal
  input  logic                  srst  , // Synchronous reset signal
  input  logic                  clr   , // Clear pipeline and output
  input  logic                  clk_en, // Clock enable signal
  input  logic  [NUM_INPUT-1:0] inp   , // Input signals (NUM_INPUT-width vector)
  output logic                  out     // Output signal
);

  // Pipeline to store intermediate states of inputs
  logic [(PIPE_DEPTH*NUM_INPUT)-1:0] pipe;

  // Generate block for pipeline implementation
  generate
    if (PIPE_DEPTH > 0) begin
      // Capture input signals in the first pipeline stage
      assign pipe = {inp[NUM_INPUT-1], inp[NUM_INPUT-2], ..., inp[0]};
      
      // Propagate data through pipeline stages
      for (genvar i = 1; i < PIPE_DEPTH; i++) begin
        assign pipe[i*NUM_INPUT-1:i*NUM_INPUT] = pipe[(i-1)*NUM_INPUT-1:i*NUM_INPUT-1];
      end
    end
  endgenerate

  // Output logic
  assign out = (pipe[PIPE_DEPTH*NUM_INPUT-1] && pipe[(PIPE_DEPTH-1)*NUM_INPUT-1] && ... && pipe[(0)]);

endmodule
