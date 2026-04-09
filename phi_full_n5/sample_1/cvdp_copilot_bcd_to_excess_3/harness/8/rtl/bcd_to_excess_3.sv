module bcd_to_excess_3(
    input clk,                     // Clock signal
    input rst,                     // Reset signal (active high)
    input enable,                  // Enable signal
    input [3:0] bcd,               // 4-bit BCD input
    output reg [3:0] excess3,       // 4-bit Excess-3 output
    output reg error,              // Error flag
    output reg parity,             // Parity bit
    output reg [1:0] error_code     // Error code (00: No error, 01: Invalid input)
);

    // State variables for sequential logic
    reg [1:0] state, next_state;

    // Combinational logic for parity calculation
    assign parity = ^bcd;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 2'b00;
            excess3 <= 4'b0000;
            error <= 1'b0;
            error_code <= 2'b00;
        end else begin
            state <= next_state;
        end
    end

    // State transition logic
    always @(state or enable) begin
        case (state)
            2'b00: begin
                if (enable) begin
                    if (bcd >= 4'b0000 && bcd <= 4'b0100) begin
                        next_state <= 2'b01;
                        excess3 <= 4'b0011;
                    end else begin
                        next_state <= 2'b00;
                        error <= 1'b1;
                        error_code <= 2'b01;
                    end
                end
            end
            2'b01: begin
                if (bcd >= 4'b0101 && bcd <= 4'b0110) begin
                    next_state <= 2'b02;
                    excess3 <= 4'b0100;
                end else begin
                    next_state <= 2'b00;
                    error <= 1'b1;
                    error_code <= 2'b01;
                end
            end
            2'b02: begin
                if (bcd >= 4'b0111 && bcd <= 4'b0111) begin
                    next_state <= 2'b03;
                    excess3 <= 4'b0110;
                end else begin
                    next_state <= 2'b00;
                    error <= 1'b1;
                    error_code <= 2'b01;
                end
            end
            2'b03: begin
                if (bcd >= 4'b0110 && bcd <= 4'b0111) begin
                    next_state <= 2'b04;
                    excess3 <= 4'b0111;
                end else begin
                    next_state <= 2'b00;
                    error <= 1'b1;
                    error_code <= 2'b01;
                end
            end
            2'b04: begin
                next_state <= 2'b00;
                excess3 <= 4'b0000;
                error <= 1'b1;
                error_code <= 2'b01;
            end
            default: next_state <= 2'b00;
        end
    end

endmodule
