module sync_serial_communication_top (
    input wire clk,
    input wire reset_n,
    input wire [63:0] data_in,
    input wire [2:0] sel,
    output wire [63:0] data_out,
    output bit done
);

// Instantiate transmitter and receiver modules
tx_block uut_tx (
    .clk(clk),
    .reset_n(reset_n),
    .data_in(data_in),
    .sel(sel),
    .serial_out(serial_out),
    .done(done_tx),
    .serial_clk(serial_clk)
);

rx_block uut_rx (
    .clk(clk),
    .reset_n(reset_n),
    .data_in(serial_out),
    .sel(sel),
    .data_out(data_out),
    .done(done_rx)
);

endmodule
