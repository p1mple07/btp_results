module barrel_shifter #(parameter DATA_WIDTH=16,parameter SHIFT_BITS_WIDTH=4)(input [DATA_WIDTH-1:0]data_in,input [SHIFT_BITS_WIDTH-1:0] shift_bits, input rotate_left_right, output [DATA_WIDTH-1:0]data_out);
localparam DATA_WIDTH_BIT_SIZE = $clog2(DATA_WIDTH);
localparam SHIFT_BITS_WIDTH_BIT_SIZE = $clog2(SHIFT_BITS_WIDTH);
genvar i;
generate
  for(i=0;i<SHIFT_BITS_WIDTH;i++) begin : gen_rotate_bits
    assign data_out[i] = rotate_left_right? data_in[(i+1)%DATA_WIDTH_BIT_SIZE] : data_in[i];
  end : gen_rotate_bits

  for(i=SHIFT_BITS_WIDTH;i<DATA_WIDTH_BIT_SIZE;i++) begin : gen_regular_shift_bits
    assign data_out[i] = data_in[(i+1)%DATA_WIDTH_BIT_SIZE];
  end : gen_regular_shift_bits

  for(i=0;i<DATA_WIDTH_BIT_SIZE;i++) begin : gen_regular_rotate_bits
    assign data_out[i] = rotate_left_right? data_in[((i+1)%SHIFT_BITS_WIDTH_BIT_SIZE)+SHIFT_BITS_WIDTH_BIT_SIZE] : data_in[i+SHIFT_BITS_WIDTH_BIT_SIZE];
  end : gen_regular_rotate_bits

endgenerate

endmodule