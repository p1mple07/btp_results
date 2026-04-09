module axis_resize (
  inputclk,          //Global clock signal: Signals are sampled on the rising edge of clk
  inputresetn,       //The global reset signal: resetn is synchronous active-LOW reset.
  input s_valid,     //The s_axis_valid signal indicates that the slave is driving a valid transfer.
  output reg s_ready, //The s_axis_ready indicates that the slave can accept a transfer in the current cycle.
  input [15:0] s_data, //The s_axis_data is the primary payload data from slave.
  output reg m_valid, //The m_axis_valid indicates that the master is driving a valid transfer.
  input m_ready,      //The m_axis_ready indicates that the slave can accept a transfer in the current cycle.
  output reg [7:0] m_data //The m_axis_data is the primary payload data to master.
);

  // FIFO buffer for 16-bit data
  reg [15:0] data_FIFO;

  // State machine control
  always @(posedge clk or posedge resetn) begin
    if (resetn) begin
      data_FIFO = 0;
      m_data = 0;
      s_ready = 1;
    elsif s_valid begin
      data_FIFO = s_data;
      s_ready = 1;
    elsif m_ready begin
      if (data_FIFO[7:0]) begin
        m_data = data_FIFO[7:0];
        m_valid = 1;
        data_FIFO = data_FIFO[15:8];
      end else if (data_FIFO[15:8]) begin
        m_data = data_FIFO[15:8];
        m_valid = 1;
        data_FIFO = 0;
      end
    end
  end
endmodule