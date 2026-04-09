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
    for(i = 0; i < row*col; i = i+1) begin
      // Use a case statement to select the correct embedding based on bpp:
      // bpp = 00: No embedding (output equals img_in)
      // bpp = 01: Embed 2 bits from data_in
      // bpp = 10: Embed 3 bits from data_in
      // bpp = 11: Embed 4 bits from data_in
      case(bpp)
        2'b00: assign img_out[(i*8)+7:(i*8)] = img_in[(i*8)+7:(i*8)];
        2'b01: assign img_out[(i*8)+7:(i*8)] = {img_in[(i*8)+7:(i*8)+2], data_in[(2*i)+1], data_in[2*i]};
        2'b10: assign img_out[(i*8)+7:(i*8)] = {img_in[(i*8)+7:(i*8)+3], data_in[(3*i)+2], data_in[(3*i)+1], data_in[3*i]};
        2'b11: assign img_out[(i*8)+7:(i*8)] = {img_in[(i*8)+7:(i*8)+4], data_in[(4*i)+3], data_in[(4*i)+2], data_in[(4*i)+1], data_in[4*i]};
        default: assign img_out[(i*8)+7:(i*8)] = img_in[(i*8)+7:(i*8)];
      endcase
    end
  endgenerate

endmodule