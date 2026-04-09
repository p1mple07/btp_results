module piso_8bit(
  input wire clk,
  input wire rst,
  output reg serial_out
);
  
  reg [7:0] tmp;

  always @(posedge clk or posedge rst) begin
    if(rst) begin
      tmp <= 8'b1000001;
    end else begin
      tmp <= {tmp[6:0], 1'b1}; // Shift left by 1 bit and add a 1 at the most significant bit
    end
  end

  assign serial_out = tmp[7];

endmodule