module bcd_to_excess_3(
    input clk,                       // Clock signal for synchronous operation
    input rst,                       // Reset signal for synchronous reset (active high)
    input enable,                    // Enable signal to control module operation
    input [3:0] bcd,                 // 4-bit BCD input
    output reg [3:0] excess3,         // 4-bit Excess-3 code output
    output reg error,                 // Error flag indicating invalid input
    output reg parity,                // Parity bit calculated as XOR of all BCD input bits
    output reg [1:0] error_code       // Error code indicating the nature of the error
);

    // Internal variables
    logic [3:0] temp_excess3;

    // Reset block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            excess3 <= 4'b0000;
            error <= 1'b0;
            parity <= 1'b0;
            error_code <= 2'b00;
        end else if (enable) begin
            // Normal operation block
            always @(bcd or enable) begin
                if (bcd == 4'b0000 || bcd == 4'b0001 || bcd == 4'b0010 || bcd == 4'b0011 ||
                    bcd == 4'b0100 || bcd == 4'b0101 || bcd == 4'b0110 || bcd == 4'b0111 ||
                    bcd == 4'b1000 || bcd == 4'b1001) begin
                    // Calculate Excess-3 and parity
                    temp_excess3 = bcd + 4'b0010;
                    parity = bcd[3] ^ bcd[2] ^ bcd[1] ^ bcd[0];
                    error_code <= 2'b00;
                end else begin
                    // Handle invalid BCD inputs
                    excess3 <= 4'b0000;
                    error <= 1'b1;
                    error_code <= 2'b01;
                end
            end
        end
    end

endmodule
