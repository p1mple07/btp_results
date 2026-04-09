module glitch_free_mux(
  input wire sel,
  input wire clk1,
  input wire clk2,
  input wire rst_n,
  output logic clkout
);

  always @(posedge clk1 or posedge clk2) begin
    if (rst_n == 1) begin
      clkout <= 0;
    end else begin
      if (sel == 0) begin
        clkout <= clk1;
      end else begin
        clkout <= clk2;
      end
    end
  end

endmodule