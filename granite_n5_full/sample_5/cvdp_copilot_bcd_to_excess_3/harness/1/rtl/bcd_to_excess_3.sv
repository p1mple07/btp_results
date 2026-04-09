module bcd_to_excess_3(bcd, excess3, error);
  // Define input and output ports
  input [3:0] bcd;
  output [3:0] excess3;
  output error;
  
  // Calculate Excess-3 code
  assign excess3 = bcd + 4'b1100;
  
  // Check if BCD input is valid
  always @(bcd or excess3) begin
    case (bcd)
      4'b1000: error <= 1'b1; // Set error flag for 10
      4'b1001: error <= 1'b1; // Set error flag for 11
      4'b1010: error <= 1'b1; // Set error flag for 12
      4'b1011: error <= 1'b1; // Set error flag for 13
      4'b1100: error <= 1'b1; // Set error flag for 14
      default: error <= 1'b0; // Clear error flag for other values
    endcase
  end
  
endmodule