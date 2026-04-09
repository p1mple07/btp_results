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
      always @(posedge clk or posedge srst) begin
          if (srst == 1'b1) begin
              // Reset pipeline and output
              pipe <= {PIPE_DEPTH{1'b0}};
              out  <= 1'b0;
          end else if (clk_en == 1'b1) begin
              // Propagate input signals through pipeline stages
              for (i=0; i<PIPE_DEPTH; i++) begin
                  pipe[i*(NUM_INPUT)+:NUM_INPUT] <= inp;
              end

              // Compute output based on the state of the final pipeline stage
              out <= &pipe[(PIPE_DEPTH-1)*(NUM_INPUT)+:NUM_INPUT];
          end else begin
              // Retain pipeline values when clk_en is low
              out <= out;
          end
      end
  endgenerate

endmodule