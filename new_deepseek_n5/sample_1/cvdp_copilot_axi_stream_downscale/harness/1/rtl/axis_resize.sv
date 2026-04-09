module axis_resize (
  input clock,
  input resetn,
  input s_valid,
  input [15:0] s_data,
  output reg s_ready,
  input m_ready,
  output reg [7:0] m_data
);

  // FIFO buffer with depth 2
  fifo buffer [1] [8:0]fifo_data (
    input clock,
    input [7:0] data,
    output reg valid,
    output reg done
  );

  // Assign data to FIFO
  always @posedge clock begin
    if (m_ready) begin
      fifo_data Valid = 1;
      fifo_data Done = 0;
    end
  end

  // When reset is active, output is 0
  if (resetn) begin
    s_ready = 1;
    m_valid = 0;
    m_data = 8'b0;
    fifo_valid = 0;
    fifo_done = 1;
    return;
  end

  // Split data into two parts
  reg [7:0] d1, d2;
  d1 = s_data[15:8];
  d2 = s_data[7:0];

  // FIFO initialization
  fifo_valid = 0;
  fifo_done = 1;

  // Transfer data to master
  always @posedge clock begin
    if (m_ready) begin
      if (fifo_valid) begin
        m_data = (d1 << 8) | d2;
        fifo_valid = 0;
        fifo_done = 1;
      end
    end
  end

  // Update s_ready when master is ready
  s_ready = m_ready;

endmodule