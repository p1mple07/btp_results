
module low_power_channel (
  // Clock/Reset
  input  logic        clk,
  input  logic        reset,

  // FIFO Interface
  input  logic        if_wakeup_i,
  logic         wr_valid_i,
  logic [7:0]   wr_payload_i,
  logic         wr_done_i,
  logic         rd_valid_i,
  logic         qreqn_i,

  // Sync FIFO Interface
  input  logic        push_i,
  input  logic [DATA_W-1:0] push_data_i,

  output wire       pop_data_o,

  // Outputs
  output wire       qacceptn_o,
  output wire       qactive_o,
  output logic        qreqn_o,
  output logic        wr_flush_o
);

  // Instantiate the FIFO
  sync_fifo #(.DEPTH(8), .DATA_W(8)) dut_fifo (
    .clk(clk),
    .reset(reset),
    .push_i(push_i),
    .push_data_i(push_data_i),
    .pop_i(pop_data_o),
    .full_o(full_o),
    .empty_o(empty_o),
    .qactive_o(qactive_o)
  );

  // Instantiate the control unit
  low_power_ctrl #(.CLK(clk), .RESET(reset)) dut_ctrl (
    .clk(clk),
    .reset(reset),
    .if_wakeup_i(if_wakeup_i),
    .wr_valid_i(wr_valid_i),
    .wr_payload_i(wr_payload_i),
    .wr_flush_o(wr_flush_o),
    .wr_done_i(wr_done_i),
    .rd_valid_i(rd_valid_i),
    .rd_payload_o(rd_payload_o),
    .qreqn_i(qreqn_i),
    .qacceptn_o(qacceptn_o),
    .qactive_o(qactive_o)
  );

  // Wire up the FIFO push/pop
  assign dut_fifo.push_i = wr_valid_i & ~wr_fifo_full;
  assign dut_fifo.pop_i = rd_valid_i & ~wr_fifo_empty;

  // Connect control outputs to FIFO outputs
  assign dut_fifo.full_o = dut_ctrl.full_o;
  assign dut_fifo.empty_o = dut_ctrl.empty_o;
  assign dut_fifo.qactive_o = dut_ctrl.qactive_o;
  assign dut_fifo.qacceptn_o = dut_ctrl.qacceptn_o;
  assign dut_fifo.qreqn_o = dut_ctrl.qreqn_o;
  assign dut_fifo.wr_flush_o = dut_ctrl.wr_flush_o;

  // Connect the FIFO outputs to low_power_ctrl outputs
  assign dut_ctrl.wr_flush_o = dut_fifo.full_o;
  assign dut_ctrl.qacceptn_o = dut_fifo.qacceptn_o;
  assign dut_ctrl.qactive_o = dut_fifo.qactive_o;
  assign dut_ctrl.wr_done_i = dut_fifo.wr_done_i;

  // Connect reset and clock to appropriate places
  assign reset = reset;
  assign clk = clk;

endmodule
