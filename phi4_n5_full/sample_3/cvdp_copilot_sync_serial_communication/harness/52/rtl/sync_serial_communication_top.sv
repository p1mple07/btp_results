
module sync_serial_communication_tx_rx(
    input clk,                     
    input reset_n,                 
    input [2:0] sel,               
    input [63:0] data_in,          
    output [63:0] data_out,        
    output done                   
);
...
