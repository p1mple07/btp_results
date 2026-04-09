module piso_8bit(
  input clk, // Positive edge triggered input clock
  input rst, // Active low reset signal
  output reg serial_out // Data shifted out of the register
);

reg [7:0] tmp; // Internal 8-bit register to store the value

always @(posedge clk or posedge rst) begin
  if (rst == 1'b0) begin
    tmp <= 8'b0000001; // Initialize the internal register to the desired value
  end else begin
    if (tmp == 8'b1111111) begin
      tmp <= 8'b0000000; // Reset the internal register to 0 after reaching its maximum value
    end else begin
      tmp <= tmp + 1'b1; // Increment the internal register by 1
    end
  end

  // Shift out the current value of the internal register
  serial_out <= tmp[7]; // Assuming the least significant bit is transmitted first
end

endmodule