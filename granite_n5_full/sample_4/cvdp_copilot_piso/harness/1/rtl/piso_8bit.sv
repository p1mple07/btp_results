module piso_8bit (
  input  bit clk,
  input  bit rst,
  output bit serial_out
);

reg [7:0] tmp;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    tmp <= 8'h01;
  end else begin
    if (tmp == 8'hff) begin
      tmp <= 8'h00;
    end else begin
      tmp <= tmp + 1;
    end
  end
end

assign serial_out = tmp[0];

endmodule