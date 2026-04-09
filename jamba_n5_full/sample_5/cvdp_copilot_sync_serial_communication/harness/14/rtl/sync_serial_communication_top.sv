`timescale 1ns / 1ps

module sync_serial_communication_tx_rx(
    input clk,                     // Clock signal
    input reset_n,                 // Active-low reset signal
    input [2:0] sel,               // Selection signal for TX block
    input [63:0] data_in,          // 64-bit data input for TX block
    output [63:0] data_out,        // 64-bit data output from RX block
    output done                    // Done signal indicating completion
);

// Tx Block Enhancements
module tx_block(
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg serial_out,
    output reg done,
    output serial_clk,
    output parity,   // New parity output
    output [63:0] data_out,
    output done
);

    // … existing internal logic …

    // Parity calculation
    wire parity;
    always @(posedge clk) begin
        if (sel == 3'b000) begin
            data_reg <= 64'h0;
            parity <= 1'b0;
        end else if (sel == 3'b001) begin
            data_reg <= {56'h0, data_in[7:0]};
            parity <= data_reg[63];
        end else if (sel == 3'b010) begin
            data_reg <= {48'h0, data_in[15:0]};
            parity <= data_reg[63];
        end else if (sel == 3'b011) begin
            data_reg <= data_in[63:0];
            parity <= data_reg[0];
        end else begin
            data_reg <= 64'h0;
            parity <= 1'b0;
        end
    end

    assign data_out = data_reg;
    assign serial_clk = clk && (temp_reg_count !== 7'd0);
    assign serial_out = data_reg[0];
    assign done = bit_count == 64'd1;
    assign parity_in = ...;   // This line is kept for context
    assign parity_error = !(parity == data_reg[0]);

endmodule

// Rx Block
module rx_block(
    input wire clk,
    input wire reset_n,
    input wire data_in,
    input wire serial_clk,
    input wire [2:0] sel,
    output reg done,
    output reg [63:0] data_out,
    output reg [63:0] data_reg,
    output done,
    output parity_in,
    output parity_error
);

    // … existing internal logic …

    // New outputs
    assign parity_in = ...;   // Keep as per original
    assign parity_error = !(parity_in == data_reg[0]);

endmodule
