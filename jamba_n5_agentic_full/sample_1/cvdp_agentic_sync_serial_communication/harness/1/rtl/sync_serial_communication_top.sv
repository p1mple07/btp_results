module sync_serial_communication_tx_rx (
    input wire clk,
    input wire reset_n,
    input wire [2:0] sel,
    input wire [63:0] data_in,
    output wire done,
    output reg [63:0] data_out,
    output reg [63:0] gray_out
);

    // Instantiate tx_block, rx_block, binary_to_gray_conversion
    tx_block #(.CLK(clk), .RST_N(reset_n)) inst_tx (
        .clk(clk),
        .rst_n(reset_n),
        .sel(sel),
        .data_in(data_in),
        .serial_out(data_out),
        .done(done),
        .serial_clk(serial_clk)
    );

    tx_block #(.CLK(clk), .RST_N(reset_n)) inst_rx (
        .clk(clk),
        .rst_n(reset_n),
        .sel(sel),
        .data_in(data_out),
        .serial_in(serial_out),
        .data_out(data_out),
        .done(done),
        .serial_clk(serial_clk)
    );

    binary_to_gray_conversion #(.CLK(clk)) inst_bg (
        .data(data_out),
        .gray_out(gray_out)
    );

endmodule
