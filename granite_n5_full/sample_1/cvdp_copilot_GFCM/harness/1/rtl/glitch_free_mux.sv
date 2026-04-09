module glitch_free_mux(
  input logic clk1,
  input logic clk2,
  input logic sel,
  input logic rst_n,
  output logic clkout
);

  // Define internal signals
  logic clk1_en, clk2_en;

  always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
      clk1_en <= 1'b0;
      clk2_en <= 1'b0;
    end else begin
      clk1_en <= sel;
      clk2_en <= ~sel;
    end
  end

  assign clkout = clk1_en? clk1 : clk2;

endmodule