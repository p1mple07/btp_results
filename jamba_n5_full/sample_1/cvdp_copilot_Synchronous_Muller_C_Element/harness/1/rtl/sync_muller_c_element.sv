module sync_muller_c_element #(
  parameter NUM_INPUT  = 2,
  parameter PIPE_DEPTH = 1  // Minimum depth 1
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
  genvar i;

  // Generate block for pipeline implementation
  generate
      for (i = 0; i < PIPE_DEPTH; i++) begin
          assign pipe[i] = inp[i];
      end
  endgenerate

  // Update pipeline on clock edge
  always_ff @(posedge clk) begin
      if (clk_en) begin
          for (i = 1; i < PIPE_DEPTH; i++) begin
              pipe[i] <= pipe[i-1];
          end
      end
  end

  // Output logic
  assign out = (PIPE_DEPTH > 0) ? (pipe[PIPE_DEPTH-1]) : 0;

endmodule
