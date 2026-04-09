module bcd_to_excess_3(
    input         clk,
    input         rst,
    input         enable,
    input  [3:0]  bcd,          // 4-bit BCD input
    output reg [3:0] excess3,    // 4-bit Excess-3 output
    output reg    error,        // Error flag indicating invalid input
    output reg    parity,       // Parity bit (XOR of all bcd bits)
    output reg [1:0] error_code // Error code: 00 = No error, 01 = Invalid BCD input
);

  // Synchronous process: triggered on rising edge of clk.
  always @(posedge clk) begin
    if (rst) begin
      // Synchronous reset: set outputs to default states.
      excess3   <= 4'b0000;
      error     <= 1'b0;
      parity    <= 1'b0;
      error_code<= 2'b00;
    end else if (enable) begin
      // Check if the bcd input is in valid range (0 to 9).
      if (bcd >= 4'd10) begin
        // Invalid input: set outputs accordingly.
        excess3   <= 4'b0000;
        error     <= 1'b1;
        error_code<= 2'b01;
        // Parity calculation still computes XOR of bcd bits.
        parity    <= ^bcd;
      end else begin
        // Valid input: perform conversion and clear error.
        case (bcd)
          4'b0000: excess3 <= 4'b0011;
          4'b0001: excess3 <= 4'b0100;
          4'b0010: excess3 <= 4'b0101;
          4'b0011: excess3 <= 4'b0110;
          4'b0100: excess3 <= 4'b0111;
          4'b0101: excess3 <= 4'b1000;
          4'b0110: excess3 <= 4'b1001;
          4'b0111: excess3 <= 4'b1010;
          4'b1000: excess3 <= 4'b1011;
          4'b1001: excess3 <= 4'b1100;
          default: begin
            // Fallback case (should not occur for valid bcd values).
            excess3   <= 4'b0000;
            error     <= 1'b1;
            error_code<= 2'b01;
          end
        endcase
        error     <= 1'b0;
        error_code<= 2'b00;
        // Calculate parity as the XOR of all bits in the bcd input.
        parity    <= ^bcd;
      end
    end
  end

endmodule