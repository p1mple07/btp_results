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
  logic next_pipe;
  logic [(PIPE_DEPTH*NUM_INPUT)-1:0] next_pipe_val;
  logic [(PIPE_DEPTH*NUM_INPUT)-1:0] curr_pipe_val;

  // Pipeline logic
  generate
    // First stage
    if (i == 0)
      pipe[0] = inp;
    // Other stages
    else
      pipe[i] = pipe[i-1];
    end
  endgenerate

  // Output logic
  if (all bit val == 1)
    out = 1;
  else if (all bit val == 0)
    out = 0;
  else
    out = curr_pipe_val;
  end

endmodule