module axis_upscale (
  // Input Ports
  input wire clk,
  input wire resetn,
  input wire dfmt_enable,
  input wire dfmt_type,
  input wire dfmt_se,
  input wire s_axis_valid,
  input wire [23:0] s_axis_data,
  input wire m_axis_ready,
  
  // Output Ports
  output wire s_axis_ready,
  output reg m_axis_valid,
  output wire [31:0] m_axis_data
);

  // Local Variables
  reg [7:0] dfmt;

  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      m_axis_valid <= 1'b0;
      m_axis_data <= 32'h0000000;
    end else begin
      if (s_axis_valid && m_axis_ready) begin
        if (dfmt_enable == 1'b1) begin
          if (dfmt_type == 1'b1) begin
            m_axis_data <= {s_axis_data[23], s_axis_data};
          end else begin
            m_axis_data <= {dfmt, s_axis_data};
          end
        } else begin
          m_axis_data <= {24{s_axis_data[23]}}, s_axis_data;
        end
        m_axis_valid <= 1'b1;
      end else begin
        m_axis_valid <= 1'b0;
        m_axis_data <= 32'h0000000;
      end
    end
  end

endmodule