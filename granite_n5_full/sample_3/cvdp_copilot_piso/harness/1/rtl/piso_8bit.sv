module piso_8bit(
  input wire clk, rst, // Clock & Reset
  output reg serial_out // Shift Register output
);

reg [7:0] tmp; // Internal register to store 8 bits of data

always @(posedge clk or posedge rst) begin
  if (rst == 1'b0) begin // Active Low reset
    tmp <= 8'b1000_0001; // Initialize internal register with value 0000_0001
  end else begin
    serial_out <= tmp[0]; // Assert serial output at each positive edge of clock
    tmp <= {tmp[6:0], 1'b1}; // Increment internal register by 1 after each 8th clock cycle
    if (tmp == 8'b1111_1111) begin
      tmp <= 8'b1000_0000; // Reset internal register to value 0000_0000 after reaching its maximum value
    end
  end
end

endmodule