
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

  // Registers for downscaling
  reg [7:0] downscaled_data;

  // Always block for clocked logic
  always @(posedge clk) begin
    if (!resetn) begin
      s_ready <= 0;
      m_valid <= 0;
      m_data <= 8'b00000000;
      downscaled_data <= 8'b00000000;
    end else begin
      // Downscale the data
      downscaled_data <= s_data[7:0];

      // Set valid signals
      s_ready <= 1;
      m_valid <= 1;
      m_data <= downscaled_data;
    end
  end

endmodule

