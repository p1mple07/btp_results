module image_stego #(
  parameter row = 2,
  parameter col = 2
)(
  input  [(row*col*8)-1:0] img_in,
  input  [(row*col*4)-1:0] data_in,
  input  [1:0]             bpp,
  output [(row*col*8)-1:0] img_out
);

  // The intended behavior is as follows:
  // • When bpp == 2'b00, no bits are embedded (pass-through).
  // • When bpp == 2'b01, 2 bits are embedded (replace the lower 2 bits of each pixel).
  // • When bpp == 2'b10, 3 bits are embedded (replace the lower 3 bits of each pixel).
  // • When bpp == 2'b11, 4 bits are embedded (replace the lower 4 bits of each pixel).
  //
  // To achieve this, we use the following logic:
  // – If bpp[1] is 1, then we are in the “high-embedding” mode.
  //   • If bpp[0] is 0 (i.e. bpp==10) then embed 3 bits:
  //         keep img_in[7:3] and insert data_in[3*i +: 3].
  //   • If bpp[0] is 1 (i.e. bpp==11) then embed 4 bits:
  //         keep img_in[7:4] and insert data_in[4*i +: 4].
  // – Else (bpp[1] == 0) we are in the “low-embedding” mode.
  //   • If bpp[0] is 1 (i.e. bpp==01) then embed 2 bits:
  //         keep img_in[7:2] and insert data_in[2*i +: 2].
  //   • Otherwise (bpp==00) pass-through.
  //
  // Note: The data_in slice for each pixel is computed as:
  //   For 2 bits per pixel: data_in[2*i +: 2]
  //   For 3 bits per pixel: data_in[3*i +: 3]
  //   For 4 bits per pixel: data_in[4*i +: 4]

  genvar i;
  generate
    for(i = 0; i < row*col; i++) begin : gen_pixels
      assign img_out[(i*8)+7:(i*8)] =
        (bpp[1] == 1'b1)
          ? (bpp[0] == 1'b1
              ? { img_in[(i*8)+7:(i*8)+4], data_in[4*i +: 4] }  // bpp = 2'b11: embed 4 bits
              : { img_in[(i*8)+7:(i*8)+3], data_in[3*i +: 3] } ) // bpp = 2'b10: embed 3 bits
          : (bpp[0] == 1'b1
              ? { img_in[(i*8)+7:(i*8)+2], data_in[2*i +: 2] }   // bpp = 2'b01: embed 2 bits
              : img_in[(i*8)+7:(i*8)] );                          // bpp = 2'b00: pass-through
    end
  endgenerate

endmodule