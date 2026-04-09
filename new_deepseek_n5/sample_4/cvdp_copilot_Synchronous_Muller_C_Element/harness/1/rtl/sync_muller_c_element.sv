module sync_muller_c_element #(
  parameter NUM_INPUT  = 2,
  parameter PIPE_DEPTH = 1
) (
  input  logic                  clk,
  input  logic                  srst,
  input  logic                  clr,
  input  logic                  clk_en,
  input  logic  [NUM_INPUT-1:0] inp,
  output logic                  out
);

  // Pipeline to store intermediate states of inputs
  logic [(PIPE_DEPTH*NUM_INPUT)-1:0] pipe;
  logic prev_out;

  // Initialize pipeline with zeros
  initial begin
    pipe = { replicate({1}, PIPE_DEPTH*NUM_INPUT) };
  end

  // Generate block for pipeline implementation
  generate
    // First stage captures input when clock enable is high
    if (i == 0)
      pipe[0] = inp;
    // Subsequent stages propagate data
    else
      pipe[i] = pipe[i-1];
    end

    // If clock enable is high, update pipeline
    if (clk_en) begin
      // Update pipeline
      pipe = { replicate(inp, PIPE_DEPTH*NUM_INPUT) };
    end

    // Update output
    out = prev_out;
  endgenerate

  // Output logic
  if (prev_out) begin
    // All bits high
    out = 1;
  elsif (pipe[PIPE_DEPTH*NUM_INPUT-1] == 0) begin
    // All bits low
    out = 0;
  else
    // Retain previous state
    out = prev_out;
  end

  // Reset pipeline and output
  always begin
    if (srst || clr) begin
      pipe = { replicate(0, PIPE_DEPTH*NUM_INPUT) };
      out = 0;
    end
  end

endmodule