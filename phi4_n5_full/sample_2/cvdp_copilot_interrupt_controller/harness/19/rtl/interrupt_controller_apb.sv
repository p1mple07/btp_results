// rtl/interrupt_controller_apb.sv
module interrupt_controller_apb #(
  parameter NUM_INTERRUPTS = 4,
  parameter ADDR_WIDTH     = 8
)
(
  // System Clock and Reset for Interrupt Logic
  input  logic                      clk,
  input  logic                      rst_n,
  input  logic [NUM_INTERRUPTS-1:0] interrupt_requests,
  output logic [NUM_INTERRUPTS-1:0] interrupt_service,
  output logic                      cpu_interrupt,
  input  logic                      cpu_ack,
  output logic [$clog2(NUM_INTERRUPTS)-1:0] interrupt_idx,
  output logic [ADDR_WIDTH-1:0]     interrupt_vector,

  // APB Interface Signals
  input  logic                      pclk,
  input  logic                      presetn,