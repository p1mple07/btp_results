module pcie_endpoint(
  input clk,
  input rst_n,
  
  //... (other ports and modules to interface with)
  output [511] rx_data,
  input tx_data,
  
  //... (other input/output ports)
  output reg [1023:0] tlp,
  input logic [31:0] data,
  
  //... (other FSMs and state registers)
  fsm_rx_state_machine,
  fsm_tx_state_machine,
  reg [31:0] current_state,
  reg [31:0] current_address,
  reg [31:0] current_address.
  
endmodule

module fsm_rx_state_machine(
  input clk,
  input rst_n,
  
  //... (other input/output ports)
  output reg [1023:0] tlp,
  input logic [31:0] data,
  
  //... (other FSMs and state registers)
  reg [31:0] current_address,
  reg [31:0] current_address,
  reg [31:0] current_data.

endmodule

module fsm_tx_state_machine(
  input clk,
  input rst_n,
  
  //... (other input/output ports)
  output reg [1023:0] tlp,
  input logic [31:0] data,
  
  //... (other FSMs and state registers)
  fsm_rx_state_machine,
  fsm_tx_state_machine,
  fsm_testbench.
   
endmodule

module testbench(
  input clk,
  input rst_n,
  
  //... (other input/output ports)
  output reg [1023:0] tlp,
  input logic [31:0] data,
  
  //... (other FSMs and state registers)
  reg [1023:0] tlp,
  reg [31:0] data,
  
  //... (other FSMs and state registers)
  fsm_rx_state_machine,
  fsm_tx_state_machine,
  fsm_rx_state_machine,
  fsm_tx_state_machine,
  fsm_rx_state_machine,
  fsm_tx_state_machine,
  fsm_testbench,
  fsm_rx_state_machine,
  fsm_tx_state_machine,
  fsm_rx_state_machine,
  fsm_tx_state_machine,
   
endmodule