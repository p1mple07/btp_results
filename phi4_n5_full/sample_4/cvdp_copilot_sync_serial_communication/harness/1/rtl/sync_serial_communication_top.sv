module.

module sync_serial_communication_top (
  input  logic         clk,
  input  logic         reset_n,  // Active LOW asynchronous reset
  input  logic [63:0]  data_in,  // Data input for TX
  input  logic [2:0]   sel,      // Controls the data width for TX (and RX)
  output logic [63:0]  data_out, // Data output from RX
  output logic         done      // Indicates valid result from RX (HIGH for one clk cycle)
);

  // Wires connecting the TX and RX blocks
  wire logic serial_out;
  wire logic serial_clk;
  wire logic rx_done;
  wire logic [63:0] rx_data_out;

  // Instantiate the transmitter block
  tx_block u_tx (
    .clk       (clk),
    .reset_n   (reset_n),
    .data_in   (data_in),
    .sel       (sel),
    .serial_out(serial_out),
    .done      (),  // TX done is not used at top-level
    .serial_clk(serial_clk)
  );

  // Instantiate the receiver block
  rx_block u_rx (
    .clk        (clk),
    .reset_n    (reset_n),
    .data_in    (serial_out),
    .sel        (sel),
    .serial_clk (serial_clk),
    .data_out   (rx_data_out),
    .done       (rx_done)
  );

  // Drive top-level outputs from the RX block outputs
  assign data_out = rx_data_out;
  assign done     = rx_done;

endmodule