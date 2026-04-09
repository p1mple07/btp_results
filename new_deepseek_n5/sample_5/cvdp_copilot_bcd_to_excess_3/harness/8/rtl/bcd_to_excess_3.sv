module bcd_to_excess_3(
    input [3:0] bcd,          // 4-bit BCD input
    input clock,             // Clock signal
    input rst,               // Reset signal
    input enable,            // Enable signal
    output reg [3:0] excess3, // 4-bit Excess-3 output
    output reg parity,       // Parity bit (XOR of BCD inputs)
    output reg error,        // Error flag
    output reg error_code    // Error code (00=ok, 01=invalid)
);

// Initial state
initial begin
    excess3 = 4'b0000;
    parity = 1'b0;
    error = 1'b0;
    error_code = 2'b00;
    // Reset on falling edge of rst
    if (rst) begin
        excess3 = 4'b0000;
        parity = 1'b0;
        error = 1'b0;
        error_code = 2'b00;
    end
    // Reset on falling edge of rst
    else begin
        excess3 = 4'b0000;
        parity = 1'b0;
        error = 1'b0;
        error_code = 2'b00;
    end
end

// Synchronous to the rising edge of clock
always clocked begin
    if (!enable) begin
        excess3 = 4'b0000;
        error = 1'b0;
        parity = 1'b0;
        error_code = 2'b00;
    else begin
        case (bcd)
            4'b0000: excess3 = 4'b0011; parity = 1'b0; error = 1'b0;
            4'b0001: excess3 = 4'b0100; parity = 1'b0; error = 1'b0;
            4'b0010: excess3 = 4'b0101; parity = 1'b0; error = 1'b0;
            4'b0011: excess3 = 4'b0110; parity = 1'b0; error = 1'b0;
            4'b0100: excess3 = 4'b0111; parity = 1'b0; error = 1'b0;
            4'b0101: excess3 = 4'b1000; parity = 1'b1; error = 1'b1;
            4'b0110: excess3 = 4'b1001; parity = 1'b1; error = 1'b1;
            4'b0111: excess3 = 4'b1010; parity = 1'b1; error = 1'b1;
            4'b1000: excess3 = 4'b1011; parity = 1'b1; error = 1'b1;
            4'b1001: excess3 = 4'b1100; parity = 1'b1; error = 1'b1;
            default: begin
                excess3 = 4'b0000;
                parity = 1'b0;
                error = 1'b1;
                error_code = 2'b01;
            end
        endcase
    end
end

endmodule