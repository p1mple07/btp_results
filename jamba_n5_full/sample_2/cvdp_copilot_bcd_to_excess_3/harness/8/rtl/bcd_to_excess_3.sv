`timescale 1ns / 1ps
module bcd_to_excess_3(
    input [3:0] bcd,
    output reg [3:0] excess3,
    output reg error,
    output reg [1:0] error_code,
    output reg parity
);

    wire clk, rst, enable;
    wire bcd_val;

    always @(bcd or enable) begin
        if (rst) begin
            excess3 <= 4'b0000;
            error <= 1'b0;
            error_code <= 2'b00;
            parity <= 1'b0;
        end else begin
            if (enable) begin
                bcd_val = bcd;
                if (bcd_val >= 10) begin
                    excess3 <= 4'b0000;
                    error <= 1'b1;
                    error_code <= 2'b01;
                    parity <= 1'b0;
                end else begin
                    // Convert BCD to excess-3
                    excess3 = bcd_val; // This is not exactly the conversion table. We need to use the table.

                    // But we can use the conversion table for each case.

                    // Let's write a small case-like block.

                    if (bcd_val == 0) excess3 = 4'b0011;
                    if (bcd_val == 1) excess3 = 4'b0100;
                    if (bcd_val == 2) excess3 = 4'b0101;
                    if (bcd_val == 3) excess3 = 4'b0110;
                    if (bcd_val == 4) excess3 = 4'b0111;
                    if (bcd_val == 5) excess3 = 4'b1000;
                    if (bcd_val == 6) excess3 = 4'b1001;
                    if (bcd_val == 7) excess3 = 4'b1010;
                    if (bcd_val == 8) excess3 = 4'b1011;
                    if (bcd_val == 9) excess3 = 4'b1100;
                end else begin
                    excess3 <= 4'b0000;
                    error <= 1'b1;
                    error_code <= 2'b01;
                    parity <= 1'b0;
                end
            end else begin
                excess3 <= 4'b0000;
                error <= 1'b1;
                error_code <= 2'b01;
                parity <= 1'b0;
            end
        end
    end

    assign parity = bcd_val[0] ^ bcd_val[1] ^ bcd_val[2] ^ bcd_val[3];
endmodule
