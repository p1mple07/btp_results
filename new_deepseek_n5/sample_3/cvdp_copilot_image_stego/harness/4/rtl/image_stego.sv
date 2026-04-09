module image_stego #(
  parameter row = 2,
  parameter col = 2
)(
  input  [(row*col*8)-1:0] img_in,
  input  [(row*col*4)-1:0] data_in,
  input  [1:0]             bpp,
  output [(row*col*8)-1:0] img_out
);

  genvar i;
  generate
    for(i = 0; i < row*col; i++) begin
      if (bpp == 2'b10 || bpp == 2'b11) begin
        assign img_out[(i*8)+7:(i*8)] = (bpp[1] == 1'b1
                                       ? {img_in[(i*8)+7 : (i*8)+2], data_in[2*i], data_in[2*i+1]} 
                                       : img_in[(i*8)+7 : (i*8)]);
      else begin
        assign img_out[(i*8)+7:(i*8)] = (bpp[1] == 1'b0
                                       ? {img_in[(i*8)+7 : (i*8)+1], data_in[i]}
                                       : img_in[(i*8)+7 : (i*8)]);
      end
    end
  endgenerate

endmodule