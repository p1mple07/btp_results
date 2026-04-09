Module: piso_8bit
// Description: This module generates 8-bit data continuously in an incremental manner 
// through a Parallel In Serial Out (PISO) shift register. The data is shifted out in 
// MSB-to-LSB order so that, for example, when the internal register holds 8'b0000_0001, 
// the first clock cycle outputs 0 (MSB) and the eighth outputs 1 (LSB). After every 8 
// clock cycles, the internal 8-bit register (data_reg) is incremented by 1 (wrapping 
// from 1111_1111 to 0000_0000). The shifting process is controlled by a clock and an 
// asynchronous active LOW reset. During reset, the serial_out is forced to logic LOW.

module piso_8bit (
  input  logic clk,       // Clock signal (50:50 duty cycle)
  input  logic rst,       // Asynchronous active LOW reset
  output logic serial_out // Serial output data
);

  // Internal registers
  reg [7:0] data_reg;   // Holds the current 8-bit value to be shifted out
  reg [7:0] shift_reg;  // Shift register for serial output
  reg [2:0] bit_count;  // Counter to track the number of bits shifted out

  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      // Asynchronous reset: initialize registers and force serial_out low
      data_reg   <= 8'b0000_0001;
      shift_reg  <= 8'b0000_0000;
      bit_count  <= 3'b000;
      serial_out <= 1'b0;
    end else begin
      if (bit_count == 3'b000) begin
        // Start of a new 8-bit period: load the shift register with the current value
        shift_reg <= data_reg;
        // Increment data_reg for the next cycle (wraps from 1111_1111 to 0000_0000)
        data_reg  <= data_reg + 1;
      end

      // Shift out the MSB of shift_reg on each clock cycle
      serial_out <= shift_reg[7];
      shift_reg  <= shift_reg >> 1;
      bit_count  <= bit_count + 1;
    end
  end

endmodule