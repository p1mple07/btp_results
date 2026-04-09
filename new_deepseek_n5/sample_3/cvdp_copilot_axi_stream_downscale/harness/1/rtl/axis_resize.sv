module axis_resize (
  inputclk,          //Global clock signal: Signals are sampled on the rising edge of clk
  inputresetn,       //The global reset signal: resetn is synchronous active-LOW reset.
  input s_valid,     //The s_axis_valid signal indicates that the slave is driving a valid transfer.
  input [15:0] s_data, //The s_axis_data is the primary payload data from slave.
  output reg s_ready, //The s_axis_ready indicates that the slave can accept a transfer in the current cycle.
  input m_ready,      //The m_axis_ready indicates that the slave can accept a transfer in the current cycle.
  output reg [7:0] m_data //The m_axis_data is the primary payload data to master.
);

  reg state = 0; // 0: reset, 1: waiting for first byte, 2: waiting for second byte, 3: done

  always @posedge clk begin
    case(state)
      0:
        if (resetn)
          m_data = 0;
          m_valid = 0;
          s_ready = 0;
          state = 1;
        else if (m_ready)
          state = 1;
      1:
        if (s_valid)
          m_data = s_data[7:0];
          state = 2;
      2:
        if (s_valid)
          m_data = (s_data[15:8] << 8) | m_data;
          m_valid = 1;
          s_ready = 1;
          state = 3;
      3:
        // No action needed, wait for next cycle
      endcase
    end
  endmodule

endmodule