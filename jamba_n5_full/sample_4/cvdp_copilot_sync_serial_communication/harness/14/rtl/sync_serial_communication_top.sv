`timescale 1ns / 1ps
module sync_serial_communication_tx_rx(
    input clk,
    input reset_n,
    input [2:0] sel,
    input [63:0] data_in,
    output [63:0] data_out,
    output done,
    output serial_clk,
    output parity,
    input parity_in,
    output parity_error
);

// Tx block enhancements
module tx_block(
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg serial_out,
    output reg done,
    output serial_clk,
    output parity
);

reg [63:0] data_reg;
reg [6:0] bit_count;
reg [6:0] reg_count;
reg [6:0] temp_reg_count;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_reg <= 64'h0;
        bit_count <= 7'h0;
        reg_count <= 7'h0;
    end else begin
        if (done == 1'b1) begin
            // ... (rest of the state machine remains unchanged)
        end
        else if (bit_count > 7'h0) begin
            data_reg <= data_reg >> 1;
            bit_count <= bit_count - 1'b1;
        end
        reg_count <= bit_count;
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        temp_reg_count <= 7'h0;
    end
    else begin
        temp_reg_count <= reg_count;
    end
end

// Compute parity for selected data
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        parity <= 1'b0;
    end else begin
        parity <= data_reg[0];
        for (int i = 1; i < 64; i++) begin
            parity = parity ^ data_reg[i];
        end
    end
end

// Output parity and associated signals
always @(*) begin
    parity_out = parity;
end

// Rx block enhancements
module rx_block(
    input wire clk,
    input wire reset_n,
    input wire data_in,
    input wire serial_clk,
    input [2:0] sel,
    output reg done,
    output reg [63:0] data_out,
    output reg [63:0] data_reg,
    output reg [63:0] data_out_serial,
    output done,
    output serial_clk,
    output parity_in,
    output parity_error
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
            // ... (rest of the state machine remains unchanged)
        end
        else if (count >= bit_count && count != 8'd0) begin
            done <= 1'b1;
            case(sel)
                3'b000: data_out <= 64'h0;
                3'b001: data_out <= {56'h0, data_reg};
                3'b010: data_out <= {48'h0, data_reg};
                3'b011: data_out <= {32'h0, data_reg};
                3'b100: data_out <= data_reg;
                default: data_out <= 64'h0;
            endcase
        end
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        count <= 8'd0;
        done <= 1'b0;
        data_out <= 64'h0;
        data_reg <= 64'h0;
    end else begin
        if (count >= bit_count && count != 8'd0) begin
            count <= count + 1'b1;
            done <= 1'b0;
        end
        else begin
            count <= 8'd0;
            done <= 1'b0;
        end
    end
end

// Parity comparison
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        parity_in <= 8'b0;
    end else begin
        parity_in <= data_out;
    end
end

assign parity_error = parity_in != parity_out;

endmodule
