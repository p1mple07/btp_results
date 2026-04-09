`timescale 1ns / 1ps

module bcd_to_excess_3(
    input         clk,
    input         rst,
    input         enable,
    input [3:0]  bcd,
    output reg    [3:0]  excess3,
    output reg    [1:0]  error,
    output reg    [1:0]  error_code
);

    // Local variables
    logic [3:0]  decimal;
    logic        parity;
    logic        is_valid;

    // Convert BCD to decimal (only for valid range checks)
    assign decimal = bcd;
    assign is_valid = (bcd >= 0 && bcd <= 9);

always @(posedge clk or posedge rst or enable) begin
    if (rst) begin
        excess3 <= 4'b0000;
        error      <= 1'b0;
        parity     <= 1'b0;
        error_code <= 2'b00;
    end else if (enable) begin
        if (is_valid) begin
            excess3 = bcd + 3'b000;  // excess-3 addition
            parity = bcd[0] ^ bcd[1] ^ bcd[2] ^ bcd[3];
        end else begin
            excess3 <= 4'b0000;
            error      <= 1'b1;
            error_code  = 2'b01;
        end
    end else begin
        excess3 <= 4'b0000;
        error      <= 1'b0;
        parity     <= 1'b0;
        error_code <= 2'b00;
    end
end

endmodule
