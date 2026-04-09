module bcd_to_excess_3(
    input clk,
    input rst,
    input enable,
    input [3:0] bcd,
    output reg [3:0] excess3,
    output reg error,
    output reg parity,
    output reg [1:0] error_code
);

  // Synchronous process triggered on the rising edge of clk or asynchronous reset.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      excess3      <= 4'b0000;
      error        <= 1'b0;
      parity       <= 1'b0;
      error_code   <= 2'b00;
    end else if (enable) begin
      // Calculate parity as the XOR of all bits in bcd.
      parity <= bcd[0] ^ bcd[1] ^ bcd[2] ^ bcd[3];

      // Check if the bcd input is within the valid range 0 to 9.
      if ((bcd >= 4'b0000) && (bcd <= 4'b1001)) begin
        // Valid input: perform BCD to Excess-3 conversion.
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
          default: excess3 <= 4'b0000; // Should not occur for valid input.
        endcase
        error       <= 1'b0;
        error_code  <= 2'b00;
      end else begin
        // Invalid input: set outputs to indicate error.
        excess3   <= 4'b0000;
        error     <= 1'b1;
        error_code<= 2'b01;
      end
    end
    // When enable is not asserted, the outputs retain their previous values.
  end

endmodule