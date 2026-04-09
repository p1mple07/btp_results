module bcd_to_excess_3(
  input wire [3:0] bcd,
  output reg [3:0] excess3,
  output reg error
);

  always @(*) begin
    if ((bcd >= 6'd10) && (bcd <= 6'd15)) begin
      excess3 = 4'b0;
      error = 1;
    end else begin
      excess3 = bcd + 4'b0011;
      error = 0;
    end
  end

endmodule