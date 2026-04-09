module priority_encoder_8x3 (input [7:0] in, output reg [2:0] out);

initial begin
  out = 3'b000;
end

always_comb begin
  if (!in[7]) begin // if least significant bit is low, maybe we can avoid but not necessary
    out = 3'b000;
  end
  else begin
    localvar int highest_bit = 7;
    for (int i = 7; i >= 0; i--) begin
      if (in[i]) highest_bit = i;
      if (highest_bit == 0) break;
    end
    out = 3'b{highest_bit};
  end
end

endmodule
