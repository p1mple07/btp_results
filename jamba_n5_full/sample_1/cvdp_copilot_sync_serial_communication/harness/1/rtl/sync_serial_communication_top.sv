module sync_serial_communication_top (
    input wire clk,
    input wire reset_n,
    input data_in,
    input sel,
    output reg serial_out,
    output reg done,
    output serial_clk
);

// Transmitter block
module tx_block (
    input wire clk,
    input wire reset_n,
    input data_in,
    input sel,
    output reg serial_out_tx,
    output reg done_tx,
    output serial_clk_tx
);

always @(posedge clk or posedge reset_n) begin
    if (reset_n) begin
        serial_out_tx <= 1'b0;
        done_tx <= 1'b0;
        serial_clk_tx <= 1'b0;
    end else begin
        if (sel == 3'h0) serial_out_tx <= 1'b0;
        else if (sel == 3'h1) serial_out_tx <= data_in[7:0];
        else if (sel == 3'h2) serial_out_tx <= data_in[15:7];
        else if (sel == 3'h3) serial_out_tx <= data_in[31:16];
        else if (sel == 3'h4) serial_out_tx <= data_in[63:32];
        else serial_out_tx <= 1'b0;

        done_tx <= 1'b0;
        serial_clk_tx <= clk;
    end
end

endmodule

// Receiver block
module rx_block (
    input wire clk,
    input wire reset_n,
    input serial_out_tx,
    input data_in,
    input sel,
    output reg data_out,
    output reg done
);

always @(posedge clk or posedge reset_n) begin
    if (reset_n) begin
        data_out <= 64'h0;
        done <= 1'b0;
        serial_out_tx <= 1'b0;
    end else begin
        data_out <= serial_out_tx;
        done <= serial_clk_tx;
    end
end

endmodule

module sync_serial_communication_top (
    input wire clk,
    input wire reset_n,
    input data_in,
    input sel,
    output reg serial_out,
    output reg done,
    output serial_clk
);

tx_block u1 (.clk(clk), .reset_n(reset_n), .data_in(data_in), .sel(sel), .serial_out(serial_out_tx), .done(done_tx), .serial_clk(serial_clk_tx));
rx_block u2 (.clk(clk), .reset_n(reset_n), .serial_out_tx(serial_out_tx), .data_in(data_in), .sel(sel), .data_out(data_out), .done(done), .serial_clk(serial_clk_tx));

assign serial_out = serial_out_tx;
assign done = done_tx;
assign serial_clk = serial_clk_tx;

endmodule
