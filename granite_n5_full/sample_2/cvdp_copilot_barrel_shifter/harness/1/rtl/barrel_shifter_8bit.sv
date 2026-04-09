module barrel_shifter_8bit(
  input  wire [7:0] data_in,
  input  wire [2:0] shift_bits,
  input  wire        left_right,
  output reg [7:0] data_out
);

  always @(*) begin
    if (left_right == 1) begin
      data_out = {shift_bits{1'b0}, data_in};
    end else begin
      data_out = {data_in[6:0], {shift_bits{1'b0}}};
    end
  end

endmodule