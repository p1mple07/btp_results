module piso_8bit(
    input  logic clk,      // 1-bit clock
    input  logic rst,      // asynchronous active LOW reset
    output logic serial_out // 1-bit serial output
);

  // Internal 8-bit register holding the current pattern
  logic [7:0] tmp;
  // Counter to track the 8-bit shifting process
  logic [2:0] bit_count;

  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      // Initialize tmp to 0000_0001 on reset
      tmp      <= 8'b0000_0001;
      bit_count<= 3'd0;
      serial_out<= 1'b0;
    end
    else begin
      // Output the MSB of the current tmp value
      serial_out <= tmp[7];
      
      // Shift left: move the MSB out and bring in a 0 at LSB
      tmp <= tmp << 1;
      
      // Increment the bit counter
      bit_count <= bit_count + 1;
      
      // After 8 clock cycles, update the tmp register to the next pattern
      if (bit_count == 3'd7) begin
        // If tmp was 1111_1111, wrap around to 0000_0000; otherwise, increment by 1
        tmp <= (tmp == 8'b1111_1111) ? 8'b0000_0000 : tmp + 1;
        bit_count <= 3'd0;
      end
    end
  end

endmodule