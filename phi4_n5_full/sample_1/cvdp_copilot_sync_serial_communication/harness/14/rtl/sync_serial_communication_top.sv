
module sync_serial_communication_tx_rx(
    input clk,                     // Clock signal
    input reset_n,                 // Active low reset signal
    input [2:0] sel,               // Selection signal for TX block
    input [63:0] data_in,          // 64-bit data input for TX block
    output [63:0] data_out,        // 64-bit data output from RX block
    output done                    // Done signal indicating completion
);
