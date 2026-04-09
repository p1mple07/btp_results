module axis_to_uart_tx #(
   parameter int CLK_FREQ = 100 MHz,
   parameter int BIT_RATE = 115200 bps,
   parameter int BIT_PER_WORD = 8 bits by default,
   parameter int PARITY_BIT = 0,
   parameter int STOP_BITS_NUM = 1
)(
   // Input Ports
   input clk,
   input rst,
   input [7:0] data,
   input logic valid,
   
   // Output Ports
   output logic tx
);

// Define the necessary variables and signals here.

// Define the necessary variables and signals here.

// Implement the finite state machine (FSM) to control the transmission process.
// Use reg/wire/task declarations here.

// Implement the serial UART output generation here.
// Use reg/wire/task declarations here.

// Implement the clock counter to control the bit period timing here.

// Implement the data latching and parity calculation logic here.

// Implement the next state logic here.

// Write the RTL code for the `axis_to_uart_tx` module here.

endmodule