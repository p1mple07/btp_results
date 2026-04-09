module sync_serial_communication_tx_rx (
    input logic clk,
    input logic reset_n,
    input logic [2:0] sel,
    input logic [63:0] data_in,
    output logic [63:0] data_out,
    output logic done,
    output logic [63:0] gray_out
);

    // Internal modules: TX, RX, Binary to Gray
    module tx_block (
        input logic clk,
        input logic reset_n,
        input logic [2:0] sel,
        input logic [63:0] data_in,
        output logic serial_out,
        output logic done,
        output logic [63:0] serial_clk
    );
        // ... implementation ...
    endmodule

    module rx_block (
        input logic clk,
        input logic reset_n,
        input logic [2:0] sel,
        input logic [63:0] data_in,
        input logic serial_clk,
        output logic done,
        output logic [63:0] data_out,
        output logic gray_out
    );
        // ... implementation ...
    endmodule

    module binary_to_gray_conversion (
        input logic data,
        output logic gray_out
    );
        // Implementation ...
    endmodule

    tx_block uut_tx (.clk(clk), .reset_n(reset_n), .sel(sel), .data_in(data_in),
                      .serial_out(serial_out), .done(done_tx), .serial_clk(serial_clk));
    rx_block uut_rx (.clk(clk), .reset_n(reset_n), .sel(sel), .data_in(serial_out),
                      .serial_clk(serial_clk), .done(done_rx), .gray_out(gray_out));
    binary_to_gray_conversion uut_gray (.data(gray_out), .gray_out(gray_out));

endmodule
