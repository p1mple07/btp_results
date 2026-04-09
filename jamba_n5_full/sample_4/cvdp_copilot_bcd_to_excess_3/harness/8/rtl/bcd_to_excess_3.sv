module bcd_to_excess_3 (
    input [3:0] bcd,
    input wire clk,
    input wire rst,
    input wire enable,
    output reg [3:0] excess3,
    output reg error,
    output reg [1:0] error_code,
    output reg [3:0] parity
);

initial begin
    excess3 = 4'b0000;
    error = 1'b0;
    error_code = 2'b00;
    parity = 4'b0000;
end

always @(bcd, clk, rst, enable) begin
    if (rst) begin
        excess3 <= 4'b0000;
        error <= 1'b0;
        error_code <= 2'b00;
        parity <= 4'b0000;
    end else if (enable && bcd < 10) begin
        excess3 = bcd;
        parity = bcd[3] ^ bcd[2] ^ bcd[1] ^ bcd[0];
        if (bcd < 10) begin
            error <= 1'b0;
        else
            error <= 1'b1;
            error_code <= 2'b01;
        end
    } else if (enable && bcd >= 10) begin
        excess3 <= 4'b0000;
        error <= 1'b1;
        error_code <= 2'b01;
        parity <= 4'b0000;
    }
end

endmodule
