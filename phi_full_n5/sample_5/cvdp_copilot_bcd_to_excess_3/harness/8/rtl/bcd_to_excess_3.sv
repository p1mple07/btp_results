module bcd_to_excess_3(
    input clk,                     // Clock signal for synchronous operation
    input rst,                     // Reset signal for synchronous reset (active high)
    input enable,                  // Enable signal to control the module operation
    input [3:0] bcd,               // 4-bit Binary-Coded Decimal input
    output reg [3:0] excess3,       // 4-bit Excess-3 code output
    output reg error,              // Error flag indicating invalid BCD input
    output reg [1:0] error_code     // Error code indicating the nature of the error
);

    reg [3:0] parity;               // Parity bit calculated as the XOR of all bits in the BCD input

    // Synchronous reset block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            excess3 <= 4'b0000;
            error <= 1'b0;
            parity <= 1'b0;
            error_code <= 2'b00;
        end else if (enable) begin
            // Normal operation block
            always @(bcd or enable) begin
                if (enable) begin
                    case(bcd)
                        4'b0000: excess3 = 4'b0011;  
                        4'b0001: excess3 = 4'b0100;  
                        4'b0010: excess3 = 4'b0101;  
                        4'b0011: excess3 = 4'b0110;  
                        4'b0100: excess3 = 4'b0111;  
                        4'b0101: excess3 = 4'b1000;  
                        4'b0110: excess3 = 4'b1001;  
                        4'b0111: excess3 = 4'b1010;  
                        default: begin
                            excess3 = 4'b0000;   // Set output to 0 on invalid input.
                            error = 1'b1;        // Set error flag to 1 to indicate an invalid input was received.
                            error_code <= 2'b01; // Set error code to indicate invalid input.
                        end
                    endcase
                    parity <= bcd ^ {4{1'b1}}; // Calculate parity as XOR of all BCD bits.
                end
            end
        end
    end

endmodule
