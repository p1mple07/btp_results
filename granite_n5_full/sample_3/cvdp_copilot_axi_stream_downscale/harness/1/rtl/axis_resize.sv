module axis_resize (
  
  input                                           clk,          //Global clock signal: Signals are sampled on the rising edge of clk
  input                                           resetn,       //The global reset signal: resetn is synchronous active-LOW reset.
  
  input                                           s_valid,      //The s_axis_valid signal indicates that the slave is driving a valid transfer.
  output  reg                                     s_ready,      //The s_axis_ready indicates that the slave can accept a transfer in the current cycle.
  input       [15:0]  s_data,                           //The s_axis_data is the primary payload data from slave.
  
  output  reg                                     m_valid,      //The m_axis_valid indicates that the master is driving a valid transfer.
  input                                           m_ready,      //The m_axis_ready indicates that the slave can accept a transfer in the current cycle.
  output  reg [7:0] m_data                              //The m_axis_data is the primary payload data to master.
  
);

// Downscaler implementation:
always @ (posedge clk or negedge resetn) begin
  if (~resetn) begin
    // Reset the internal flip-flops to a known state
    s_ready <= 1;
    m_valid <= 0;
    m_data  <= 0;
  end else begin
    // Check if the slave has valid data
    if (s_valid) begin
      // Split the 16-bit data into two 8-bit data streams
      m_data[7:0] <= s_data[15:8];
      s_ready <= 0;
      m_valid <= 1;
    end else begin
      // If no data is available from the slave, wait until it becomes available
      s_ready <= s_ready;
      m_valid <= m_valid;
      m_data  <= m_data;
    end
    
    // Check if the master can accept more data
    if (m_ready) begin
      // Release the lock on the m_axis_valid signal
      m_valid <= 0;
    end else begin
      // Wait until the master can accept more data
      m_valid <= m_valid;
    end
  end
end

endmodule