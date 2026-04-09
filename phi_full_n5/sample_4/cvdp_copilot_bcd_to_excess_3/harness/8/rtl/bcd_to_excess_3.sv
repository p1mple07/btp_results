
timescale 1ns / 1ps
module bcd_to_excess_3(
    input clk,                           // Clock signal for synchronous operation
    input rst,                           // Reset signal for synchronous reset (active high)
    input enable,                        // Enable signal to control module operation
    input [3:0] bcd,                     // 4-bit BCD input
    output reg [3:0] excess3,            // 4-bit Excess-3 code output
    output reg error,                    // Error flag indicating invalid input
    output reg parity,                   // Parity bit calculated as XOR of all BCD input bits
    output reg [1:0] error_code           // Error code indicating the nature of the error
);

// Synchronous reset block
always @(posedge clk) begin
    if (rst) begin
        excess3 <= 4'b0000;
        error <= 1'b0;
        parity <= 1'b0;
        error_code <= 2'b00;
    end else if (enable) begin
        // Main functionality block
        // Check enable signal and proceed if asserted
        if (enable) begin
            error_code <= 2'b00;
            case(bcd)
                4'b0000: begin
                    excess3 <= 4'b0011;
                    parity <= bcd ^ 4'b0000;
                end
                4'b0001: begin
                    excess3 <= 4'b0100;
                    parity <= bcd ^ 4'b0001;
                end
                4'b0010: begin
                    excess3 <= 4'b0101;
                    parity <= bcd ^ 4'b0010;
                end
                4'b0011: begin
                    excess3 <= 4'b0110;
                    parity <= bcd ^ 4'b0011;
                end
                4'b0100: begin
                    excess3 <= 4'b0111;
                    parity <= bcd ^ 4'b0100;
                end
                4'b0101: begin
                    excess3 <= 4'b1000;
                    parity <= bcd ^ 4'b0101;
                end
                4'b0110: begin
                    excess3 <= 4'b1001;
                    parity <= bcd ^ 4'b0110;
                end
                4'b0111: begin
                    excess3 <= 4'b1010;
                    parity <= bcd ^ 4'b0111;
                end
                4'b1000: begin
                    excess3 <= 4'b1011;
                    parity <= bcd ^ 4'b1000;
                end
                4'b1001: begin
                    excess3 <= 4'b1100;
                    parity <= bcd ^ 4'b1001;
                end
                default: begin
                    error <= 1'b1;
                    excess3 <= 4'b0000;
                    error_code <= 2'b01;
                end
            end
        end else begin
            // When enable is not asserted, outputs should be in their default states
            excess3 <= 4'b0000;
            error <= 1'b0;
            parity <= 1'b0;
            error_code <= 2'b00;
        end
    end
end

endmodule
