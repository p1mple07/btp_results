`timescale 1ns / 1ps
module sync_serial_communication_tx_rx(
    input clk,
    input reset_n,
    input [2:0] sel,
    input [63:0] data_in,
    output [63:0] data_out,
    output done
);

// --- TX Block (minimized combinational logic)
module tx_block(
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg serial_out,
    output reg done,
    output serial_clk
);

reg [63:0] data_reg;
reg [6:0] bit_count;
reg [6:0] reg_count;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_reg <= 64'h0;
        bit_count <= 7'h0;
        reg_count <= 7'h0;
    end else if (done == 1'b1) begin
        // Empty body – no action needed
    end else if (bit_count > 7'h0) begin
        data_reg >>= 1;
        bit_count = bit_count - 1'b1;
    end else if (reg_count > 7'h0 || bit_count > 7'h0) begin
        serial_out = data_reg[0];
    end
end

// --- RX Block (minimized combinational logic)
module rx_block(
    input wire clk,
    input wire reset_n,
    input wire data_in,
    input wire serial_clk,
    input [2:0] sel,
    output reg done,
    output reg [63:0] data_out
);

reg [63:0] data_reg;
reg [7:0] bit_count;
reg [7:0] count;

always @(posedge serial_clk or negedge reset_n) begin
    if (!reset_n) begin
        data_reg <= 64'h0;
        bit_count <= 8'd0;
    end else begin
        if (done == 1'b1) begin
            bit_count <= 8'b0;
            data_reg <= 64'h0;
        end else begin
            bit_count <= bit_count + 1'b1;
            data_reg[bit_count] <= data_in;
        end
    end
end

endmodule

// Instantiate blocks
tx_block uut_tx_block (
    .clk(clk),
    .reset_n(reset_n),
    .data_in(data_in),
    .sel(sel),
    .serial_out(tx_out),
    .done(tx_done),
    .serial_clk(serial_clk_in)
);

rx_block uut_rx_block (
    .clk(clk),
    .serial_clk(serial_clk_in),
    .reset_n(reset_n),
    .sel(sel),
    .data_in(tx_out),
    .data_out(data_out),
    .done(done)
);

endmodule
