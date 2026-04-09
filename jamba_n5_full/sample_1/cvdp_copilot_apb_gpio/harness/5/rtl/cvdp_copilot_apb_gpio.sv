
module cvdp_copilot_apb_gpio #(
  parameter GPIO_WIDTH = 8
)(
  ...
  input logic pclk,       // Clock signal
  input logic preset_n,   // Active-low reset signal

  ...
  // Input/Output interfaces
  input logic [GPIO_WIDTH-1:0] gpio_in,     // GPIO input signals
  output logic [GPIO_WIDTH-1:0] gpio_out,   // GPIO output signals
  output logic [GPIO_WIDTH-1:0] gpio_enable, // GPIO output enable signals

  ...
);
