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
    // Pipeline logic
    if (clk_en) begin
      for (i = 0; i < PIPE_DEPTH; i++) begin
        pipe[(i+1)*NUM_INPUT + inp] = inp;
      end
    else begin
      for (i = 0; i < PIPE_DEPTH; i++) begin
        pipe[(i+1)*NUM_INPUT + inp] = pipe[i*NUM_INPUT + inp];
      end
    end
  endgenerate

  // Output logic
  if (srst or clr) begin
    out = 0;
    next_state = 0;
  else begin
    integer all_one = 1;
    integer all_zero = 0;
    for (i = 0; i < NUM_INPUT; i++) begin
      if (pipe[PIPE_DEPTH*NUM_INPUT + i] != 1) all_one = 0;
      if (pipe[PIPE_DEPTH*NUM_INPUT + i] != 0) all_zero = 1;
    end
    out = all_one or all_zero;
  end

endmodule