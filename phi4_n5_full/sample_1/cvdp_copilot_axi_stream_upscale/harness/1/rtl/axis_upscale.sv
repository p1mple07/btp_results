module axis_upscale (
    input  logic         clk,
    input  logic         resetn,
    input  logic         dfmt_enable,
    input  logic         dfmt_type,
    input  logic         dfmt_se,
    input  logic         s_axis_valid,
    input  logic [23:0]  s_axis_data,
    input  logic         m_axis_ready,
    output logic         s_axis_ready,
    output logic         m_axis_valid,
    output logic [31:0]  m_axis_data
);

  // Internal register to hold the captured upsized data and a valid flag.
  logic valid_reg;
  logic [31:0] data_reg;

  // One pipeline register stage: capture input when not busy,
  // and output registered data when the master is ready.
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      valid_reg <= 1'b0;
      data_reg  <= 32'b0;
    end
    else begin
      // Capture new data if not busy and both sides are ready.
      if (!valid_reg && s_axis_valid && m_axis_ready) begin
        valid_reg <= 1'b1;
        // Compute the upsized 32-bit data.
        // If dfmt_enable is disabled, simply prepend 8'b0.
        // If dfmt_enable is enabled:
        //   - if dfmt_se is 1, then perform sign extension using the MSB of s_axis_data.
        //     The extension bit is taken as s_axis_data[23] normally, or its inverted value if dfmt_type is 1.
        //   - if dfmt_se is 0, then the upper 8 bits are zeros.
        data_reg <= (!dfmt_enable) ?
                      {8'b0, s_axis_data} :
                      (dfmt_enable) ?
                        (dfmt_se ?
                           (dfmt_type ?
                              {8{~s_axis_data[23]}, s_axis_data} :
                              {8{s_axis_data[23]}, s_axis_data}
                           ) :
                           {8'b0, s_axis_data}
                        ) :
                      {8'b0, s_axis_data};
      end
      // When the master is ready, clear the valid flag.
      if (valid_reg && m_axis_ready)
        valid_reg <= 1'b0;
    end
  end

  // Handshake signals: when not busy, assert s_axis_ready.
  assign s_axis_ready = !valid_reg;
  assign m_axis_valid = valid_reg;
  assign m_axis_data  = data_reg;

endmodule