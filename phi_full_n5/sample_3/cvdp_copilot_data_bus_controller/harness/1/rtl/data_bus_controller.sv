module data_bus_controller #(
  parameter AFINITY = 0
) (
  input         clk,
  input         rst_n,

  output reg m0_ready,
  input         m0_valid,
  input [31:0]  m0_data,

  output reg m1_ready,
  input         m1_valid,
  input [31:0]  m1_data,

  input         s_read,
  output reg s_valid,
  output [31:0] s_data
);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      m0_ready <= 1'b0;
      m1_ready <= 1'b0;
      s_valid <= 1'b0;
    end else begin
      m0_ready <= s_ready & m0_valid & (AFINITY == 0);
      m1_ready <= s_ready & m1_valid & (AFINITY == 1);
      s_valid <= m0_ready | m1_ready;
    end
  end

  always_comb begin
    if (m0_ready) begin
      s_data <= m0_data;
    end
    if (m1_ready) begin
      s_data <= m1_data;
    end
  end

endmodule
