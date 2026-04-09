`timescale 1ns / 1ps
module sync_serial_communication_tx_rx(
    input clk,
    input reset_n,
    input [2:0] sel,
    input [63:0] data_in,
    output [63:0] data_out,
    output done,
    output [63:0] data_out_serial,
    output parity,   // New: transmitted parity bit
    output parity_error,   // New: parity mismatch indicator
    output serial_clk
);

// Tx block
module tx_block(
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg serial_out,
    output reg done,
    output serial_clk,
    output reg parity
);

    // … (original tx code, with added parity logic)

endmodule

// Rx block
module rx_block(
    input wire clk,
    input wire reset_n,
    input wire data_in,
    input wire serial_clk,
    input wire [2:0] sel,
    output reg done,
    output reg [63:0] data_out,
    output reg [63:0] data_out_serial,
    output done,
    output parity,
    output parity_error
);

    // … (original rx code, with added parity_in and parity_error)

endmodule
