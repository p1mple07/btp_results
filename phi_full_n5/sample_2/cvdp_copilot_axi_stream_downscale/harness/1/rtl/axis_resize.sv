

// Here is the SystemVerilog implementation for the `axis_resize` module

module axis_resize (

  input clk,
  input resetn,
  input s_valid,
  output reg s_ready,
  input [15:0] s_data,
  output reg m_valid,
  input m_ready,
  output reg [7:0] m_data
);

  reg [7:0] downscaled_data;

  // Reset condition
  always @ (posedge clk or negedge resetn) begin
    if (!resetn) begin
      s_ready <= 1'b0;
      m_valid <= 1'b0;
      m_data <= 8'b0;
    end else begin
      s_ready <= 1'b1;
      m_valid <= 1'b0;
      downscaled_data <= 8'b0;
    end
  end

  // Downscaling logic
  always @ (posedge clk) begin
    if (s_valid && s_ready) begin
      downscaled_data <= s_data[7:0];
      m_valid <= 1'b1;
      m_data <= downscaled_data;
    end
  end

endmodule

