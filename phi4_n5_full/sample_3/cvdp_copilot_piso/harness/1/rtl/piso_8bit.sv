module piso_8bit (
    input  logic clk,    // 1-bit clock input
    input  logic rst,    // asynchronous active LOW reset
    output logic serial_out  // 1-bit serial output
);

  // Internal 8-bit register used for pattern generation
  reg [7:0] tmp;
  // Counter to track which bit of tmp is being shifted out (0 to 7)
  reg [2:0] bit_counter;

  // On every positive edge of clk or when rst is asserted (active LOW),
  // update the internal state.
  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      // Initialize tmp to 0000_0001 and reset the bit counter.
      tmp       <= 8'b0000_0001;
      bit_counter <= 3'b000;
      // serial_out is combinational, so no need to drive it here.
    end else begin
      // Check if we have shifted out all 8 bits.
      if (bit_counter == 3'd7) begin
        // After 8 cycles, increment tmp.
        // If tmp is 8'hFF, wrap around to 0000_0000.
        if (tmp == 8'hFF)
          tmp <= 8'b0000_0000;
        else
          tmp <= tmp + 1;
        // Reset the bit counter for the next 8-bit pattern.
        bit_counter <= 3'b000;
      end else begin
        // Increment the bit counter to shift the next bit.
        bit_counter <= bit_counter + 1;
      end
    end
  end

  // Generate the serial output by selecting the appropriate bit from tmp.
  // Since the pattern is shifted out in MSB-first order:
  // When bit_counter == 0, serial_out = tmp[7] (MSB);
  // When bit_counter == 7, serial_out = tmp[0] (LSB).
  // This matches the requirement that for 0000_0001, the first output is 0 and the eighth is 1.
  assign serial_out = tmp[7 - bit_counter];

endmodule