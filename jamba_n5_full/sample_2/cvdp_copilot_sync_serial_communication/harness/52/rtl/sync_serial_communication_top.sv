`timescale 1ns / 1ps
module sync_serial_communication_tx_rx(
    input clk,
    input reset_n,
    input [2:0] sel,
    input [63:0] data_in,
    output [63:0] data_out,
    output done
);

    // Shared data for TX
    reg [63:0] data_reg;
    reg [7:0] bit_count;
    reg [7:0] reg_count;
    reg [6:0] temp_reg_count;

    // Shared data for RX
    reg [63:0] tx_out;
    reg [63:0] data_out_rx;
    reg [7:0] bit_count_rx;
    reg [7:0] reg_count_rx;
    reg [6:0] temp_reg_count_rx;

    // Synchronisation flops
    reg [6:0] serial_clk_in;
    reg [6:0] serial_clk;
    reg [6:0] tx_done;
    reg [6:0] rx_done;

    // --- TX pipeline ---
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_reg <= 64'h0;
            bit_count <= 7'h0;
            reg_count <= 7'h0;
            serial_clk_in <= clk;
        end else begin
            if (done == 1'b1) begin
                done <= 1'b0;
                bit_count <= 7'h0;
                reg_count <= 7'h0;
            end else begin
                if (bit_count > 7'h0) begin
                    data_reg <= data_reg >> 1;
                    bit_count <= bit_count - 1'b1;
                end else if (bit_count == 7'h0) begin
                    data_reg <= data_reg >> 1;
                    bit_count <= bit_count - 1'b1;
                end
                reg_count <= bit_count;
            end
        end
    end

    // --- RX pipeline ---
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_reg <= 64'h0;
            bit_count <= 8'd0;
        end else begin
            if (done == 1'b1) begin
                done <= 1'b0;
                bit_count <= 8'b0;
            end else begin
                bit_count <= bit_count + 1'b1;
                data_reg[bit_count] <= data_in;
            end
        end
    end

    // --- Serial clock generation ---
    assign serial_clk_in = clk && (temp_reg_count != 7'd0);
    assign serial_clk = clk && (temp_reg_count != 7'd0);

    // --- Data output ---
    assign data_out = data_reg[0];
    assign data_out_rx = data_reg[0];

    // --- Done signal ---
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            done <= 1'b0;
        end else begin
            if (bit_count == 7'h0) begin
                done <= 1'b1;
            end else begin
                done <= 1'b0;
            end
        end
    end

endmodule
