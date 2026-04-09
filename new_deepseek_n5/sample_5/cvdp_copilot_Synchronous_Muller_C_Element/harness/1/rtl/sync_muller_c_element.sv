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
    if (i == 0)
      pipe[0] = inp;
    else
      pipe[i] = pipe[i-1];
    endcase
  endgenerate

  if (srst || clr)
    pipe = 0;
    out = 0;
  else if (clk_en)
    if (pipe[PIPE_DEPTH*NUM_INPUT-1] == 0)
      out = 0;
    else
      out = 1;
    endcase
  else
    out = out;
  endcase
endmodule