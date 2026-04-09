module cvdp_copilot_apb_gpio #(
  parameter GPIO_WIDTH = 8
)(
  // Clock and Reset Signals
  input logic pclk,
  input logic preset_n,

  // APB Interface Inputs
  input logic psel,
  input logic [7:2] paddr,
  input logic penable,
  input logic pwrite,
  input logic [31:0] pwdata,

  // APB Interface Outputs
  output logic [31:0] prdata,
  output logic pready,
  output logic pslverr,

  // GPIO Interface Inputs and Outputs
  input logic [GPIO_WIDTH-1:0] gpio_in,
  output logic [GPIO_WIDTH-1:0] gpio_out,
  output logic [GPIO_WIDTH-1:0] gpio_enable,

  // Interrupt Outputs
  output logic [GPIO_WIDTH-1:0] gpio_int,
  output logic comb_int,

  // New Register Ports
  input logic [BITS-1:0] gpio_dir,
  input logic [BITS-1:0] power_mgmt,
  input logic [GPIO_WIDTH-1:0] interrupt_reset,

  // ... rest of the existing code
);
