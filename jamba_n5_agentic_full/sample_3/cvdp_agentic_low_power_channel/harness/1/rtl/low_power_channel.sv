module top;
  logic clk, reset, if_wakeup_i, wr_valid_i, rd_valid_i, qreqn_i, qacceptn_o, qactive_o;

  // FIFO instance
  rtl::sync_fifo #(.DEPTH(8)) dut1 (.clk(clk), .reset(reset));

  // Control logic instance
  rtl::low_power_ctrl cntl (.clk(clk), .reset(reset));

  // Wire declarations
  wire qreqn_i, qacceptn_o, qactive_o;
  wire wr_valid_i, rd_valid_i;
  wire if_wakeup_i, if_wakeup_i;

  // Connect FIFO outputs to control inputs
  dut1.wr_flush_o <= cntl.wr_flush_o;
  dut1.wr_done_i <= cntl.wr_done_i;
  dut1.rd_valid_i <= cntl.rd_valid_i;
  dut1.qreqn_i <= cntl.qreqn_i;
  dut1.qacceptn_o <= cntl.qacceptn_o;
  dut1.qactive_o <= cntl.qactive_o;

  // Connect control outputs to FIFO
  cntl.qreqn_i <= if_wakeup_i;
  cntl.qacceptn_i <= wr_valid_i;
  cntl.qactive_i <= rd_valid_i;
  cntl.wr_valid_i <= wr_valid_i;
  cntl.rd_payload_o <= dut1.rd_payload_o;
  cntl.rd_valid_i <= dut1.wr_done_i;

  // Testbench outputs
  assign rd_payload_o = dut1.rd_payload_o;
  assign qacceptn_o = dut1.qacceptn_o;
  assign qactive_o = dut1.qactive_o;

endmodule
