module bcd_to_excess_3(
    input wire [3:0] bcd,          // 4-bit BCD input
    input wire clock,             // Clock signal
    input wire rst,               // Reset signal
    input wire enable,            // Enable signal
    output reg [3:0] excess3,     // 4-bit Excess-3 output
    output reg parity,           // Parity bit (XOR of BCD bits)
    output reg error,            // Error flag
    output reg [1:0] error_code   // Error code (00=ok, 01=invalid)
);

// Synchronous initialization on rising clock edge
always @ (posedge clock) begin
    if (rst) begin
        // Reset all outputs to default states
        excess3 = 4'b0000;
        parity = 1'b0;
        error = 1'b0;
        error_code = 2'b00;
        return;
    end

    if (enable) begin
        // Calculate parity bit as XOR of all BCD bits
        parity = (bcd[3] ^ bcd[2] ^ bcd[1] ^ bcd[0]);

        // Validate BCD input
        case (bcd)
            4'b0000: excess3 = 4'b0011;
            4'b0001: excess3 = 4'b0100;
            4'b0010: excess3 = 4'b0101;
            4'b0011: excess3 = 4'b0110;
            4'b0100: excess3 = 4'b0111;
            4'b0101: excess3 = 4'b1000;
            4'b0110: excess3 = 4'b1001;
            4'b0111: excess3 = 4'b1010;
            4'b1000: excess3 = 4'b1011;
            4'b1001: excess3 = 4'b1100;
            default: begin
                // Invalid BCD input
                excess3 = 4'b0000;
                error = 1'b1;
                error_code = 2'b01;
                return;
            endcase
    end
end
endmodule