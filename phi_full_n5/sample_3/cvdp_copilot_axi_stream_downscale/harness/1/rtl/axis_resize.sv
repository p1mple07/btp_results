

module axis_resize (

  input                                           clk,          //Global clock signal: Signals are sampled on the rising edge of clk
  input                                           resetn,       //The global reset signal: resetn is synchronous active-LOW reset.

  input                                           s_valid,      //The s_axis_valid signal indicates that the slave is driving a valid transfer.
  output  reg                                     s_ready,      //The s_axis_ready indicates that the slave can accept a transfer in the current cycle.
  input       [15:0]  s_data,                                   //The s_axis_data is the primary payload data from slave.

  output  reg                                     m_valid,      //The m_axis_valid indicates that the master is driving a valid transfer.
  input                                           m_ready,      //The m_axis_ready indicates that the slave can accept a transfer in the current cycle.
  output  reg [7:0] m_data                                      //The m_axis_data is the primary payload data to master.
);

  reg [15:0] temp_data;
  always @(posedge clk) begin
    if (resetn == 1'b0) begin
      temp_data <= 16'b0;
      s_ready <= 1'b0;
      m_valid <= 1'b0;
      m_data <= 8'b0;
    end else begin
      if (s_valid == 1'b1) begin
        temp_data <= s_data;
        s_ready <= 1'b1;
        m_valid <= 1'b1;
        m_data <= {temp_data[14:8], temp_data[7]};
      end
    end
  end

endmodule
