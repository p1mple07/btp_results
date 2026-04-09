module data_bus_controller #(
  parameter AFINITY = 0
) (
  input         clk,
  input         rst_n,

  output        m0_read,
  input         m0_valid,
  input [31:0]  m0_data,

  output        m1_read,
  input         m1_valid,
  input [31:0]  m1_data,

  output        s_read,
  output        s_valid,
  output [31:0] s_data
);

  reg [31:0] slave_data;
  reg m0_ready, m1_ready;
  reg m0_valid, m1_valid;
  reg s_ready;

  always_comb begin
    // First‑come, first‑served decision based on AFINITY
    if (~m0_ready && ~m1_ready) begin
      // No masters ready – nothing happens
    end else if (m0_ready && m1_ready) begin
      if (AFINITY == 0) begin
        slave_data <= m0_data;
        m0_read = 1;
        m0_valid = 0;
        m1_ready = 1;
        m1_valid = 0;
      end else begin
        slave_data <= m1_data;
        m1_read = 1;
        m1_valid = 0;
        m0_ready = 1;
        m0_valid = 0;
      end
    end else if (m0_ready && !m1_ready) begin
      slave_data <= m0_data;
      m0_read = 1;
      m0_valid = 0;
      m1_ready = 1;
      m1_valid = 0;
    end else if (!m0_ready && m1_ready) begin
      slave_data <= m1_data;
      m1_read = 1;
      m1_valid = 0;
      m0_ready = 1;
      m0_valid = 0;
    end else
      // Both masters ready – use AFINITY to choose
      slave_data <= {m0_data, m1_data};
      m0_read = 0;
      m1_read = 0;
  end

  always_ff @(posedge clk) begin
    // Update read outputs
    m0_read = m0_valid;
    m0_valid = 0;
    m1_read = m1_valid;
    m1_valid = 0;
    s_valid = s_ready;
    s_ready = ~s_valid;
  end

  // Output the data from the masters
  assign m0_ready   = AFINITY == 0 ? 1 : 0;
  assign m1_ready   = AFINITY == 1 ? 1 : 0;
  assign s_read     = true;
  assign s_valid    = false;
  assign s_data     = {};

endmodule
