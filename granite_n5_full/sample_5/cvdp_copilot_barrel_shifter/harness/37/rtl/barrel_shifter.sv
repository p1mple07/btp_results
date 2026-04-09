module barrel_shifter #(parameter DATA_WIDTH=16, parameter SHIFT_BITS_WIDTH=4)(
  input wire [DATA_WIDTH-1:0] data_in,
  input wire [SHIFT_BITS_WIDTH-1:0] shift_bits,
  input wire rotate_left_right,
  input wire left_right,
  output reg [DATA_WIDTH-1:0] data_out
);

  always @(*) begin
    if (rotate_left_right) begin
      data_out <= {<<{data_in}} >> {{SHIFT_BITS_WIDTH{1'b0}}} & ((1<<SHIFT_BITS_WIDTH)-1);
    end else begin
      data_out <= {{SHIFT_BITS_WIDTH{1'b0}}}{>>{(~(left_right))? data_in : {1'b0}{data_in[DATA_WIDTH-2:0]}}};
    end
  end

endmodule