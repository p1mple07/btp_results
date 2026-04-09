
module tx_block(
    input clk,               // Clock input
    input reset_n,           // Active-low reset input
    input [63:0] data_in,    // 64-bit parallel data input
    input [2:0] sel,         // Selection input to choose data width
    output reg serial_out,   // Serial data output
    output reg done,         // Done signal indicating completion of transmission
    output serial_clk        // Clock for serial data transmission
);
