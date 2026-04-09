module sync_muller_c_element #(
  parameter NUM_INPUT  = 2,  // Number of input signals
  parameter PIPE_DEPTH = 1   // Number of pipeline stages (minimum 1)
) (
  input  logic                  clk,   // Clock signal
  input  logic                  srst,  // Synchronous reset (active-high)
  input  logic                  clr,   // Clear signal (clears pipeline and output)
  input  logic                  clk_en,// Clock enable signal
  input  logic [NUM_INPUT-1:0]  inp,   // Input signals (NUM_INPUT-width vector)
  output logic                  out    // Output signal
);

  // Pipeline to store intermediate states of inputs
  // The vector is partitioned into PIPE_DEPTH slices of NUM_INPUT bits each.
  logic [(PIPE_DEPTH*NUM_INPUT)-1:0] pipe;
  genvar i;

  // Generate block for pipeline implementation
  generate
    for (i = 0; i < PIPE_DEPTH; i = i + 1) begin : pipe_stage
      if (i == 0) begin : stage0
         always_ff @(posedge clk) begin
            if (srst || clr)
              pipe[0+:NUM_INPUT] <= '0;
            else if (clk_en)
              pipe[0+:NUM_INPUT] <= inp;
            // Else: retain current state when clk_en is low
         end
      end else begin : stage_other
         always_ff @(posedge clk) begin
            if (srst || clr)
              pipe[i*NUM_INPUT+:NUM_INPUT] <= '0;
            else if (clk_en)
              pipe[i*NUM_INPUT+:NUM_INPUT] <= pipe[(i-1)*NUM_INPUT+:NUM_INPUT];
            // Else: retain current state when clk_en is low
         end
      end
    end
  endgenerate

  // Output logic:
  // The output is updated based on the final pipeline stage.
  // It is set to 1 if all bits are high, 0 if all bits are low,
  // otherwise it retains its previous state.
  // Note: This creates an additional one-cycle delay, so the total latency is PIPE_DEPTH + 1 cycles.
  always_ff @(posedge clk) begin
    if (srst || clr)
      out <= 1'b0;
    else if (clk_en) begin
      logic [NUM_INPUT-1:0] final_stage;
      final_stage = pipe[(PIPE_DEPTH-1)*NUM_INPUT+:NUM_INPUT];
      if (final_stage == {NUM_INPUT{1'b1}})
        out <= 1'b1;
      else if (final_stage == {NUM_INPUT{1'b0}})
        out <= 1'b0;
      // Else: retain previous state of out
    end
    // Else: when clk_en is low, out remains unchanged
  end

endmodule