module sync_serial_communication_top (
    input clk,
    input reset_n,
    input data_in,
    input sel,
    output data_out,
    output done
);

module tx_block (
    input clk,
    input reset_n,
    input data_in,
    input [2:0] sel,
    output [63:0] serial_out,
    output done,
    output serial_clk
);

module rx_block (
    input clk,
    input reset_n,
    input data_in,
    input [2:0] sel,
    output [63:0] data_out,
    output done
);

endmodule

tx_block #(.clk(clk), .reset_n(reset_n), .data_in(data_in), .sel(sel)) u_tx (
    .serial_out(u_tx_serial_out),
    .done(u_tx_done),
    .serial_clk(u_tx_serial_clk)
);

rx_block #(.clk(clk), .reset_n(reset_n), .data_in(data_in), .sel(sel)) u_rx (
    .data_out(u_rx_data_out),
    .done(u_rx_done)
);

assign data_out = u_tx_serial_out;
assign done = u_tx_done;
