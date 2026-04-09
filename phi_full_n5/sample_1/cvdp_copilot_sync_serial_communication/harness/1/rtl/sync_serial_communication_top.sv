module sync_serial_communication_top (
    input logic clk,
    input logic reset_n,
    input logic [63:0] data_in,
    input logic [2:0] sel,
    output logic serial_clk,
    output logic data_out[63:0],
    output logic done
);

    tx_block tx(.clk(clk), .reset_n(reset_n), .data_in(data_in), .sel(sel), .serial_out(serial_clk), .done(done));
    rx_block rx(.clk(serial_clk), .reset_n(reset_n), .data_in(serial_clk), .sel(sel), .data_out(data_out), .done(done));

endmodule
