module sync_muller_c_element #(
  parameter NUM_INPUT  = 2, // Number of input signals
  parameter PIPE_DEPTH = 1  // Number of pipeline stages
) (
  input  logic                  clk  , // Clock signal
  input  logic                  srst , // Synchronous reset signal
  input  logic                  clr  , // Clear pipeline and output
  input  logic                  clk_en, // Clock enable signal
  input  logic  [NUM_INPUT-1:0] inp  , // Input signals (NUM_INPUT-width vector)
  output logic                  out     // Output signal
);

  // Pipeline to store intermediate states of inputs
  logic [(PIPE_DEPTH*NUM_INPUT)-1:0] pipe;
  genvar i;

  // Generate block for pipeline implementation
  generate
      // Insert code here for pipeline logic
      always @(posedge clk or negedge srst) begin
        if (!srst) begin
          pipe <= '0;
        end else if (clk_en &&!clr) begin
          pipe <= {pipe[PIPE_DEPTH*NUM_INPUT-1:PIPE_DEPTH*NUM_INPUT-(NUM_INPUT-1):NUM_INPUT], inp};
        end
      end
  endgenerate

  // Insert code here for Output logic
  assign out = (&pipe[PIPE_DEPTH*NUM_INPUT-1:PIPE_DEPTH*NUM_INPUT-(NUM_INPUT-1)]);

endmodule