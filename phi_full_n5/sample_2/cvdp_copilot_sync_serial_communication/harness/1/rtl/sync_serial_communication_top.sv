module sync_serial_communication_top (
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg serial_out,
    output reg done,
    output reg serial_clk
);

    wire [5:0] data_width;

    // Instantiate transmitter block
    tx_block tx_inst (.clk(clk), .reset_n(reset_n), .data_in(data_in), .sel(sel),
                     .serial_out(serial_out), .done(done), .serial_clk(serial_clk),
                     .data_width(data_width));

    // Instantiate receiver block
    rx_block rx_inst (.clk(clk), .reset_n(reset_n), .data_in(serial_out), .sel(sel),
                      .serial_clk(serial_clk), .data_out(data_out), .done(done));

    // Connect data_out to the output
    assign data_out = rx_inst.data_out;

endmodule
