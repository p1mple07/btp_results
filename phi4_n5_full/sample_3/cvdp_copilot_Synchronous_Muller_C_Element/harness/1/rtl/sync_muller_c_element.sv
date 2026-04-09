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
  genvar i;

  // Generate block for pipeline implementation
  generate
    for (i = 0; i < PIPE_DEPTH; i++) begin : pipeline_stage
      always_ff @(posedge clk) begin
        if (srst || clr) begin
          pipe[i*NUM_INPUT +: NUM_INPUT] <= '0;
        end else if (clk_en) begin
          if (i == 0)
            pipe[i*NUM_INPUT +: NUM_INPUT] <= inp;
          else
            pipe[i*NUM_INPUT +: NUM_INPUT] <= pipe[(i-1)*NUM_INPUT +: NUM_INPUT];
        end
        // When clk_en is low, retain the current value (do nothing)
      end
    end
  endgenerate

  // Output logic: compute output based on final pipeline stage
  always_ff @(posedge clk) begin
    if (srst || clr) begin
      out <= 1'b0;
    end else if (clk_en) begin
      // Final stage is the last segment of the pipeline vector
      if (pipe[(PIPE_DEPTH-1)*NUM_INPUT +: NUM_INPUT] == {NUM_INPUT{1}})
        out <= 1'b1;
      else if (pipe[(PIPE_DEPTH-1)*NUM_INPUT +: NUM_INPUT] == {NUM_INPUT{0}})
        out <= 1'b0;
      else
        out <= out; // Retain previous state if mixed values
    end
    // When clk_en is low, output retains its value
  end

endmodule