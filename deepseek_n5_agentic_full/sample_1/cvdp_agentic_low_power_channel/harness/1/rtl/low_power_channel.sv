// ******************************************************************************
// RTL Code StructureInstantiation and Connection
// ******************************************************************************
// The low_power_channel module is composed of two submodules: low_power_ctrl and sync_fifo
// These submodules are connected via their respective ports according to the DUT interface
//定义模块的输入输出口
module low_power_channel (
  // Clock and reset signals
  clk,
  reset,
  // Wakeup input
  if_wakeup_i,
  // Write/Read requests
  wr_valid_i,
  wr_payload_i,
  // Upstream flush interface
  wr_push_i,
  wr_pop_i,
  // FIFO statuses
  wr fluoride_push,
  wr fluoride_pop,
  // FIFO full/empty
  wr_full,
  wr_empty,
  // FIFO capacities
  wr_FIFO_size,
  wr_FIFO_depth,
  // FIFO push/pop controls
  wr_FIFO_push,
  wr_FIFO_pop,
  // Q-channel interface
  qreqn_i,
  qacceptn_i,
  qactive_o,
  // FIFO position
  wr_FIFO_pos,
  // Enable controls
  wr.Flush,
  wr.WakeUp,
  wr.Fluoresce,
  // Power management
  wrPowerOn,
  wrPowerOff
);

// instantiate the control unit
low_power_ctrl #(
  .clk(clk),
  .reset(reset),
  .if_wakeup_i(if_wakeup_i),
  .wr_valid_i(wr_valid_i),
  .wr_payload_i(wr_payload_i),
  .wr_push_i(wr_push_i),
  .wr_pop_i(wr_pop_i),
  .wr_flush_o(wr_flush_o),
  .wr.done_i(wr.done_i),
  .rd_valid_i(rd.valid),
  .rd_payload_i(rd.payload),
  .qreqn_i(qreqn_i),
  .qacceptn_i(qacceptn_i),
  .qactive_o(qactive_o)
) dut ctrl;

// instantiate the sync fifo
sync_fifo #(
  parameter DEPTH = 8,
  parameter DATA_W = 8
)(
  // Input signals
  input  wire              clk,
  input  wire              reset,
  input  wire              if_wakeup_i,
  input  wire              wr_valid_i,
  input  wire [DATA_W-1:0] wr_payload_i,
  input  wire              wr_push_i,
  input  wire              wr_pop_i,
  input  wire              wr_full,
  input  wire              wr_empty,
  // Output signals
  output wire              wr_flush_o,
  output wire [DATA_W-1:0] rd_payload_o,
  output wire              qacceptn_o,
  output wire              qactive_o,
  // FIFO position
  output wire [DEPTH-1:0] wr_FIFO_pos,
  // Enable controls
  output wire              wr.Flush,
  output wire              wrWakeUp,
  output wire              wr.Fluoresce,
  output wire              wrPowerOn,
  output wire              wrPowerOff
) fifo;

// Connect the FIFO and control unit
ctrl.wake_up = wrWakeUp;
ctrl.flush = wr.Flush;
ctrl.flop1_out = wrPowerOn;
ctrl.flop1_out = wrPowerOff;
ctrl.flop2_out = wrPowerOn;
ctrl.flop2_out = wrPowerOff;

// Set up initial conditions
// Assuming the control unit starts in ST_Q_RUN state initially