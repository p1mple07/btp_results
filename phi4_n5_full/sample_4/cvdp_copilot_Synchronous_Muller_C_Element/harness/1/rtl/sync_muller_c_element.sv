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

  // Pipeline Logic:
  // Each stage is updated on the rising edge of clk.
  // On reset (srst or clr), the stage is cleared to 0.
  // When clk_en is high, stage 0 captures the input, and each subsequent stage
  // propagates the previous stage's value. When clk_en is low, the pipeline retains its state.
  generate
    for (i = 0; i < PIPE_DEPTH; i = i + 1) begin : pipeline_stage
      always_ff @(posedge clk) begin
        if (srst || clr) begin
          pipe[i*NUM_INPUT +: NUM_INPUT] <= '0;
        end else if (clk_en) begin
          if (i == 0)
            pipe[i*NUM_INPUT +: NUM_INPUT] <= inp;
          else
            pipe[i*NUM_INPUT +: NUM_INPUT] <= pipe[(i-1)*NUM_INPUT +: NUM_INPUT];
        end
        // When clk_en is low, the pipeline retains its current value.
      end
    end
  endgenerate

  // To achieve a total latency of PIPE_DEPTH + 1 clock cycles,
  // we use a register (final_stage_reg) to capture the final pipeline stage
  // from the previous cycle, so that the output reflects the state with one extra cycle delay.
  logic [NUM_INPUT-1:0] final_stage_reg;

  // Output Logic:
  // The output is updated based on the final pipeline stage value captured in final_stage_reg.
  // If all bits are 1, out becomes 1.
  // If all bits are 0, out becomes 0.
  // Otherwise, out retains its previous state.
  always_ff @(posedge clk) begin
    if (srst || clr) begin
      final_stage_reg <= '0;
      out <= 1'b0;
    end else begin
      if (clk_en)
        final_stage_reg <= pipe[(PIPE_DEPTH-1)*NUM_INPUT +: NUM_INPUT];
      // final_stage_reg holds the value from the previous cycle,
      // ensuring an additional clock cycle delay for the output.
      if (final_stage_reg == {NUM_INPUT{1'b1}})
        out <= 1'b1;
      else if (final_stage_reg == {NUM_INPUT{1'b0}})
        out <= 1'b0;
      else
        out <= out;
    end
  end

endmodule