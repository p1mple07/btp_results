module barrel_shifter #(parameter DATA_WIDTH=16, parameter SHIFT_BITS_WIDTH=4) (
  input  [DATA_WIDTH-1:0] data_in,
  input  [SHIFT_BITS_WIDTH-1:0] shift_bits,
  input                           left_right,
  input                           rotate_left_right,
  output [DATA_WIDTH-1:0] data_out
);

  always @(*) begin
    if (rotate_left_right == 0) begin
      data_out = ((left_right == 1)?
        ({data_in[DATA_WIDTH-1:shift_bits], data_in[DATA_WIDTH-2:0]}) :
        ({data_in[shift_bits:0], data_in[DATA_WIDTH-1:shift_bits]}));
    end else begin
      data_out = ((left_right == 1)?
        ({data_in[DATA_WIDTH-1:shift_bits], data_in[DATA_WIDTH-2:0]}) :
        ({data_in[shift_bits:0], data_in[DATA_WIDTH-1:shift_bits]}));
    end
  end

endmodule