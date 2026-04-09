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

  //-------------------------------------------------------------------------
  // Internal registers for one pipeline stage
  //-------------------------------------------------------------------------
  logic [31:0] data_reg;
  logic        valid_reg;

  //-------------------------------------------------------------------------
  // Combinational logic to compute the upsized data.
  // When dfmt_enable is disabled, the output is simply the 24-bit input
  // padded with 8 zeros (i.e. {8'd0, s_axis_data}).
  // When dfmt_enable is enabled, the MSB of the input (bit 23) is used
  // to form the upsized word:
  //   - If dfmt_type is 1, then the inverted MSB (~s_axis_data[23]) is used;
  //     if dfmt_type is 0, then the original MSB is used.
  //   - If dfmt_se is 1, then the chosen MSB is sign‐extended to the upper 8 bits;
  //     if dfmt_se is 0, then the upper 8 bits are zero.
  // The lower 24 bits are formed by replacing the original MSB with the chosen value.
  //-------------------------------------------------------------------------
  logic [31:0] out_data;

  always_comb begin
    // Default assignment
    out_data = 32'd0;
    if (dfmt_enable) begin
      // Determine the bit value for the MSB based on dfmt_type.
      // If dfmt_type is 1, use the inverted MSB; otherwise, use the original.
      logic bit_val;
      bit_val = (dfmt_type ? ~s_axis_data[23] : s_axis_data[23]);

      // If sign extension is enabled, replicate bit_val in the upper 8 bits.
      // Otherwise, use 8 zeros.
      if (dfmt_se)
        out_data = { {8{bit_val}}, { s_axis_data[22:0], bit_val } };
      else
        out_data = {8'd0, { s_axis_data[22:0], bit_val } };
    end
    else begin
      // When dfmt_enable is disabled, simply pad the input with 8 zeros.
      out_data = {8'd0, s_axis_data};
    end
  end

  //-------------------------------------------------------------------------
  // Pipeline register stage: capture and forward the data and valid signal.
  // s_axis_ready is driven by m_axis_ready to indicate when the module is
  // ready to accept new data.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      valid_reg   <= 1'b0;
      data_reg    <= 32'd0;
      s_axis_ready<= 1'b0;
    end
    else begin
      // Drive s_axis_ready based on the master ready signal.
      s_axis_ready <= m_axis_ready;

      // When both sides are ready, capture the new data.
      if (s_axis_valid && m_axis_ready) begin
        valid_reg <= 1'b1;
        data_reg  <= out_data;
      end
      // When the current valid data is accepted, deassert valid.
      else if (m_axis_valid && m_axis_ready) begin
        valid_reg <= 1'b0;
      end
      // Otherwise, hold the current valid state.
    end
  end

  // Drive the master valid signal from the registered valid flag.
  assign m_axis_valid = valid_reg;

endmodule