module sync_muller_c_element #(
  parameter NUM_INPUT  = 2, // Number of input signals
  parameter PIPE_DEPTH = 1  // Number of pipeline stages
) (
  input  logic                  clk,   // Clock signal
  input  logic                  srst,  // Synchronous reset signal
  input  logic                  clr,   // Clear pipeline and output
  input  logic                  clk_en, // Clock enable signal
  input  logic  [NUM_INPUT-1:0] inp,   // Input signals (NUM_INPUT-width vector)
  output logic                  out    // Output signal
);

  // Pipeline to store intermediate states of inputs
  // Total bits = PIPE_DEPTH * NUM_INPUT
  logic [(PIPE_DEPTH*NUM_INPUT)-1:0] pipe;
  genvar i;

  // Generate block for pipeline implementation
  generate
    for (i = 0; i < PIPE_DEPTH; i = i + 1) begin : pipeline_stages
      always_ff @(posedge clk) begin
        // Priority: synchronous reset (srst) takes precedence, then clr.
        if (srst) begin
          pipe[i*NUM_INPUT +: NUM_INPUT] <= '0;
        end else if (clr) begin
          pipe[i*NUM_INPUT +: NUM_INPUT] <= '0;
        end else if (clk_en) begin
          // For the first stage, capture the input signals.
          if (i == 0)
            pipe[i*NUM_INPUT +: NUM_INPUT] <= inp;
          // For subsequent stages, propagate data from the previous stage.
          else
            pipe[i*NUM_INPUT +: NUM_INPUT] <= pipe[(i-1)*NUM_INPUT +: NUM_INPUT];
        end
        // If clk_en is low, the pipeline retains its current state.
      end
    end
  endgenerate

  // Output logic: Computed from the final pipeline stage.
  // The output is updated only when clk_en is high.
  // - If all bits in the final stage are high, out becomes 1.
  // - If all bits are low, out becomes 0.
  // - Otherwise, out retains its previous state.
  always_ff @(posedge clk) begin
    if (srst || clr) begin
      out <= 1'b0;
    end else if (clk_en) begin
      // Final pipeline stage is at index PIPE_DEPTH - 1.
      if (&pipe[(PIPE_DEPTH-1)*NUM_INPUT +: NUM_INPUT])
        out <= 1'b1;
      else if (!|pipe[(PIPE_DEPTH-1)*NUM_INPUT +: NUM_INPUT])
        out <= 1'b0;
      else
        out <= out; // Retain previous state when inputs are mixed.
    end
    // When clk_en is low, out remains unchanged.
  end

endmodule