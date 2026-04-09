module bcd_to_excess_3(
    input         clk,
    input         rst,
    input         enable,
    input  [3:0]  bcd,          // 4-bit BCD input
    output reg [3:0] excess3,    // 4-bit Excess-3 output
    output reg    error,        // Error flag for invalid input
    output reg    parity,       // Parity bit (XOR of all bcd bits)
    output reg [1:0] error_code // Error code: 00 = no error, 01 = invalid input
);

    // Synchronous process triggered on rising edge of clk
    always @(posedge clk) begin
        if (rst) begin
            // Synchronous reset: set outputs to default values
            excess3   <= 4'b0000;
            error     <= 1'b0;
            parity    <= 1'b0;
            error_code<= 2'b00;
        end else if (enable) begin
            // Calculate parity as the XOR of all bits in the bcd input
            parity <= ^bcd;
            
            // Check if the bcd input is valid (0 to 9)
            if (bcd >= 4'd10) begin
                // Invalid input: set outputs accordingly
                excess3   <= 4'b0000;
                error     <= 1'b1;
                error_code<= 2'b01;
            end else begin
                // Valid input: convert bcd to Excess-3 and clear error flag
                excess3   <= case(bcd)
                                4'b0000: 4'b0011;
                                4'b0001: 4'b0100;
                                4'b0010: 4'b0101;
                                4'b0011: 4'b0110;
                                4'b0100: 4'b0111;
                                4'b0101: 4'b1000;
                                4'b0110: 4'b1001;
                                4'b0111: 4'b1010;
                                4'b1000: 4'b1011;
                                4'b1001: 4'b1100;
                                default: 4'b0000;
                            endcase;
                error     <= 1'b0;
                error_code<= 2'b00;
            end
        end
        // When enable is de-asserted, outputs retain their previous values.
    end

endmodule