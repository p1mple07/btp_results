module axis_to_uart_tx #(
  parameter int CLK_FREQ    = 100 MHz
 , parameter int BIT_RATE = 115200 bps
 , parameter int BIT_PER_WORD = 8 bits
 , parameter int PARITY_BIT = 0
 , parameter int STOP_BITS_NUM = 1
)(
  // Input Ports
  input wire aclk
 , input wire aresetn
 , input wire [BIT_PER_WORD-1:0] tdata
 , input wire tvalid
 , input wire tready
  
  // Output Ports
 , output reg tready
);

// Local Parameters
localparam int CLK_FREQ_HZ = 100 MHz
, localparam int BIT_RATE = 115200 bps
, localparam int BIT_PER_WORD = 8 bits
, localparam int PARITY_BIT = 0
, localparam int STOP_BITS_NUM = 1
)

// Include the RTL code of the module
include "rtl/axis_to_uart_tx_rtl.sv".

// Define the module
module axis_to_uart_tx(
  // Input Ports
  input wire aclk
 , input wire aresetn
 , input wire [7:0] tdata
 , input wire tvalid
 , input wire tready
  
  // Output Ports
 , output reg tready
);

// Implement the RTL code for the UART transmitter
always @ (posedge clk) begin
    if (tvalid)
    
    assign tx.v (from rtl/verilog/). This file contains the RTL code for the UART transmitter.
    #if (tvalid).
    
endmodule