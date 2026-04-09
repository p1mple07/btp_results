// File: rtl/precision_counter_axi.sv
// Description: A configurable AXI4‐Lite Slave module implementing a high‐precision
// countdown counter with start/stop control, interrupt generation based on a configurable
// threshold, and elapsed time tracking after countdown completion.
//
// The module implements the AXI4‐Lite protocol with proper handshaking, flow control,
// and error responses for unsupported addresses.
//
// Register Map:
//   Offset  Register              Description
//   0x00    slv_reg_ctl           Control register (bit0: start/stop countdown; write resets elapsed time)
//   0x10    slv_reg_t             Elapsed time counter
//   0x20    slv_reg_v             Countdown value (decrements by 1 per clock when running)
//   0x24    slv_reg_irq_mask      Interrupt mask register (bit0 enables interrupts)
//   0x28    slv_reg_irq_thresh    Interrupt threshold register (interrupt asserted when slv_reg_v == this value)
//
// Additional outputs:
//   axi_ap_done - Asserted when countdown reaches 0.
//   irq         - Asserted when (slv_reg_v == slv_reg_irq_thresh) and irq mask is enabled.
//
// Default values on reset: All registers are 0 and the countdown is stopped.

module precision_counter_axi #(
  parameter C_S_AXI_DATA_WIDTH = 32,
  parameter C_S_AXI_ADDR_WIDTH = 8
)(
  input  wire                   axi_aclk,
  input  wire                   axi_aresetn,
  // Write Address Channel
  input  wire [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
  input  wire                   axi_awvalid,
  output reg                    axi_awready,
  // Write Data Channel
  input  wire [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
  input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
  input  wire                   axi_wvalid,
  output reg                    axi_wready,
  // Write Response Channel
  output reg [1:0]              axi_bresp,
  output reg                    axi_bvalid,
  input  wire                   axi_bready,
  // Read Address Channel
  input  wire [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
  input  wire                   axi_arvalid,
  output reg                    axi_arready,
  // Read Data Channel
  output reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
  output reg [1:0]              axi_rresp,
  output reg                    axi_rvalid,
  input  wire                   axi_rready,
  // Control Outputs
  output wire                   axi_ap_done,
  output wire                   irq
);

  //----------------------------------------------------------------