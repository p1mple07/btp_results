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
    for (genvar i = 0; i < PIPE_DEPTH; i++) begin : pipeline_stage
      assign pipe[i*NUM_INPUT:(i+1)*NUM_INPUT-1] = inp;
    end
  endgenerate

  // Output logic
  always_comb begin
    if (clk_en) begin
      // Check if all inputs in the final stage are high or low
      out = ((pipe[PIPE_DEPTH*NUM_INPUT-1] == 1) && (pipe[(PIPE_DEPTH-1)*NUM_INPUT] == 1)) ? 1 : 0;
    end else
      out = pipe[PIPE_DEPTH*NUM_INPUT-1]; // Retain previous state when clk_en is low
  end

endmodule
