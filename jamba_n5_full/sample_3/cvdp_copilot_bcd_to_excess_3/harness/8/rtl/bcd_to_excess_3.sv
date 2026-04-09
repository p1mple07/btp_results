`timescale 1ns / 1ps
module bcd_to_excess_3(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [3:0] bcd,
    output reg [3:0] excess3,
    output reg error,
    output reg parity,
    output reg error_code
);

    initial begin
        if (rst) begin
            excess3 <= 4'b0000;
            error <= 1'b0;
            parity <= 1'b0;
            error_code <= 2'b00;
        end else begin
            always @(posedge clk or posedge rst) begin
                if (!rst) begin
                    excess3 <= 4'b0000;
                    error <= 1'b0;
                    parity <= 1'b0;
                    error_code <= 2'b00;
                } else begin
                    if (enable && (bcd[3:0] >= 0 && bcd[3:0] <= 9)) begin
                        excess3 = bcd;
                        parity = bcd[3] ^ bcd[2] ^ bcd[1] ^ bcd[0];
                        if (bcd[3] == bcd[2] && bcd[2] == bcd[1] && bcd[1] == bcd[0]) begin
                            error_code = 2'b00;
                        } else begin
                            error_code = 2'b01;
                        end
                        error = 1'b0;
                    ] else begin
                        excess3 = 4'b0000;
                        parity = 1'b0;
                        error = 1'b1;
                        error_code = 2'b01;
                    end
                end
            end
        end
    end

endmodule
