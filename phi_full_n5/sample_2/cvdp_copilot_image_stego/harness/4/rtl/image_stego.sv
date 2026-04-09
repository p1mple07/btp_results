
module image_stego #(
  parameter row = 2,
  parameter col = 2
)(
  input  [(row*col*8)-1:0] img_in,
  input  [(row*col*4)-1:0] data_in,
  input  [2:0]            bpp,
  output [(row*col*8)-1:0] img_out
);

  genvar i;
  generate
    for(i = 0; i < row*col; i++) begin
      if (bpp == 2'b10) begin
        // Embed two bits from data_in for each pixel
        assign img_out[(i*8)+7:(i*8)+1] = data_in[2*i+1];
        assign img_out[(i*8)+6:(i*8)+2] = data_in[2*i];
      end else if (bpp == 2'b11) begin
        // Embed three bits from data_in for each pixel
        assign img_out[(i*8)+7:(i*8)+1] = data_in[2*i+1];
        assign img_out[(i*8)+6:(i*8)+2] = data_in[2*i];
        assign img_out[(i*8)+5:(i*8)+6] = data_in[2*i+0];
      end else begin
        // For bpp=00 and bpp=01, pass through img_in
        assign img_out[(i*8)+7:(i*8)+1] = img_in[(i*8)+7:(i*8)+1];
      end
    end
  endgenerate

endmodule
