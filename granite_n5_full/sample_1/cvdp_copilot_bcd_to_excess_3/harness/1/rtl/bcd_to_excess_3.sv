module bcd_to_excess_3 (
  input [3:0] bcd,
  output reg [3:0] excess3,
  output reg error
);
  
  always @(*) begin
    if(bcd >= 10 && bcd <= 15) begin
      excess3 = 4'b0; // Set Excess-3 to 0 for invalid input
      error = 1'b1; // Assert error flag
    end else begin
      excess3 = bcd + 3; // Convert BCD to Excess-3
      error = 1'b0; // Clear error flag
    end
  end
  
endmodule