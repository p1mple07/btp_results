module piso_8bit (
    input  logic clk,
    input  logic rst,
    output logic serial_out
);

  // Internal 8-bit register holding the current pattern
  logic [7:0] tmp;
  // 3-bit counter to track the number of bits shifted out (0 to 7)
  logic [2:0] bit_counter;

  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      // Asynchronous active LOW reset: initialize tmp to 8'b0000_0001 and clear counter/output
      tmp         <= 8'b0000_0001;
      bit_counter <= 3'b000;
      serial_out  <= 1'b0;
    end else begin
      if (bit_counter < 3'b111) begin
        // Output the MSB of tmp and increment the counter
        serial_out  <= tmp[7];
        bit_counter <= bit_counter + 1;
      end else begin
        // After 8 bits have been shifted, output the MSB of tmp,
        // increment tmp by 1 (modulo 256), and reset the counter.
        serial_out  <= tmp[7];
        tmp         <= tmp + 1;  // 1111_1111 + 1 wraps to 0000_0000 automatically
        bit_counter <= 3'b000;
      end
    end
  end

endmodule