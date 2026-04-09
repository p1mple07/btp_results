module implements a low-power communication channel capable of
//   managing data transfer, wakeup control, and Q-channel handshaking.
//   It utilizes a synchronous FIFO for buffering writes and a control unit
//   for managing data flow and power states.
// Port Definition:
//   - Clock (clk): System clock driving the communication channel.
//   - Reset (rst): Global reset signal.
//   - Wakeup Input (if_wakeup_i): Signal to wake up the channel.
//   - Write Enable (wr_valid_i): enables writing to FIFO.
//   - Write Data (wr_payload_i): data to be written to FIFO.
//   - Write Done (wr_done_i): indicates successful write operation.
//   - Read Valid (rd_valid_i): indicates valid read operation.
//   - Read Data (rd_payload_o): read data from FIFO.
//   - Q-Channel Request (qreqn_i): request to transfer data from FIFO.
//   - Q-Channel Acceptance (qacceptn_o): acceptance signal from FIFO.
//   - Q-Active (qactive_o): indicates active state in Q-channel.

module low_power_channel (
  // Clock and reset
  input  logic       clk,
  input  logic       rst,
  // FIFO interface
  input  logic        if_wakeup_i,
  input  logic        wr_valid_i,
  input  logic [7:0] wr_payload_i,
  input  logic        wr_done_i,
  output logic [7:0] rd_payload_o,
  output logic        qacceptn_o,
  output logic        qactive_o,
  // FIFO parameters
  parameter DEPTH   = 8,
  parameter DATA_W  = 8
);

  // instantiate FIFO
  sync_fifo#DEPTH#DATA_W (fifo, wr, rd) (
    .clk(clk),
    .reset(rst),
    .push_i(if_wakeup_i),
    .push_data_i(wr_payload_i),
    .wr_flush_o(wr_flush_o),
    .wr_done_i(wr_done_i),
    .rd_valid_i(rd_valid_i),
    .rd_payload_o(rd_payload_o),
    .qreqn_i(qreqn_i),
    .qacceptn_o(qacceptn_o)
  );

  // instantiate control unit
  low_power_ctrl low_powerctrl (
    .clk(clk),
    .rst(rst),
    .if_wakeup_i(if_wakeup_i),
    .wr_valid_i(wr_valid_i),
    .wr_payload_i(wr_payload_i),
    .wr_flush_i(wr_flush_o),
    .wr_done_i(wr_done_i),
    .rd_valid_i(rd_valid_i),
    .rd_payload_o(rd_payload_o),
    .qreqn_i(qreqn_i),
    .qacceptn_o(qacceptn_o),
    .qactive_o(qactive_o)
  );
endmodule