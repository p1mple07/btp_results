module glitch_free_mux (
    input  logic clk1,
    input  logic clk2,
    input  logic sel,
    input  logic rst_n,
    output logic clkout
);

  // Internal clock enable signals for glitch‐free switching.
  // When sel = 0, clk1 is enabled; when sel = 1, clk2 is enabled.
  // The enables are updated on the rising edges of their respective clocks.
  logic clk1_en;
  logic clk2_en;

  // On the rising edge of clk1, update clk1_en.
  // When sel transitions from 0 to 1 (synchronously with clk1), clk1 is disabled.
  always_ff @(posedge clk1 or negedge rst_n) begin
    if (!rst_n)
      clk1_en <= 1'b0;
    else
      clk1_en <= ~sel;
  end

  // On the rising edge of clk2, update clk2_en.
  // When sel transitions from 1 to 0 (synchronously with clk2), clk2 is disabled.
  always_ff @(posedge clk2 or negedge rst_n) begin
    if (!rst_n)
      clk2_en <= 1'b0;
    else
      clk2_en <= sel;
  end

  // Generate clkout as the OR of the gated clocks.
  // Since clk1 and clk2 are assumed to be synchronous with a fixed phase difference,
  // they are non-overlapping and the OR operation is glitch free.
  assign clkout = (clk1_en ? clk1 : 1'b0) | (clk2_en ? clk2 : 1'b0);

endmodule