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

  logic [(PIPE_DEPTH*NUM_INPUT)-1:0] pipe;
  genvar i;

  generate
    // Initialize pipeline with input values
    assign pipe[0*NUM_INPUT + 0] = inp[0];
    assign pipe[0*NUM_INPUT + 1] = inp[1];
    
    // Propagate through pipeline stages
    for (i = 1; i < PIPE_DEPTH; i++) begin
      assign pipe[i*NUM_INPUT + 0] = pipe[(i-1)*NUM_INPUT + 0];
      assign pipe[i*NUM_INPUT + 1] = pipe[(i-1)*NUM_INPUT + 1];
    end
  endgenerate

  // Compute output based on final pipeline stage
  assign out = 1;
  for (i = 0; i < NUM_INPUT; i++) begin
    if (pipe[PIPE_DEPTH*NUM_INPUT - 1 + i] != 1)
      out = 0;
    else
      out = 1;
  end
  if (out == 0 && !clk_en) out = 0;

  // Reset pipeline and output
  always begin
    if (srst || clr) begin
      pipe = 0;
      out = 0;
    end
  end

endmodule