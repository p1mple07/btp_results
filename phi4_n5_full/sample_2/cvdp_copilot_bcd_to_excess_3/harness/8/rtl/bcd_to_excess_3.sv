module bcd_to_excess_3(
    input         clk,         // Clock signal for synchronous operation
    input         rst,         // Synchronous reset (active high)
    input         enable,      // Enable signal for module operation
    input  [3:0]  bcd,         // 4-bit Binary-Coded Decimal input
    output reg [3:0] excess3,  // 4-bit Excess-3 code output
    output reg     error,      // Error flag for invalid BCD input
    output reg     parity,     // Parity bit (XOR of all bits in bcd)
    output reg [1:0] error_code // Error code: 00 = No error, 01 = Invalid input
);

    // Synchronous process: triggered on rising edge of clock
    always @(posedge clk) begin
        if (rst) begin
            // Reset outputs to default values
            excess3   <= 4'b0000;
            error     <= 1'b0;
            parity    <= 1'b0;
            error_code<= 2'b00;
        end else if (enable) begin
            // Compute parity as XOR of all bits in bcd
            parity <= bcd[0] ^ bcd[1] ^ bcd[2] ^ bcd[3];

            // Check if the input is within valid BCD range (0 to 9)
            if (bcd >= 4'd0 && bcd <= 4'd9) begin
                // Valid BCD input: compute Excess-3 conversion
                case (bcd)
                    4'd0: excess3 <= 4'b0011;  // 0 -> 3
                    4'd1: excess3 <= 4'b0100;  // 1 -> 4
                    4'd2: excess3 <= 4'b0101;  // 2 -> 5
                    4'd3: excess3 <= 4'b0110;  // 3 -> 6
                    4'd4: excess3 <= 4'b0111;  // 4 -> 7
                    4'd5: excess3 <= 4'b1000;  // 5 -> 8
                    4'd6: excess3 <= 4'b1001;  // 6 -> 9
                    4'd7: excess3 <= 4'b1010;  // 7 -> 10
                    4'd8: excess3 <= 4'b1011;  // 8 -> 11
                    4'd9: excess3 <= 4'b1100;  // 9 -> 12
                    default: excess3 <= 4'b0000;
                endcase
                error     <= 1'b0;          // No error
                error_code<= 2'b00;         // Error code 00: No error
            end else begin
                // Invalid BCD input: set outputs for error condition
                excess3   <= 4'b0000;       // Output forced to 0
                error     <= 1'b1;          // Assert error flag
                error_code<= 2'b01;         // Error code 01: Invalid input
            end
        end
        // If enable is not asserted, outputs retain their previous state
    end

endmodule