module barrel_shifter #(parameter DATA_WIDTH = 16, parameter SHIFT_BITS_WIDTH = 4) (
  input [DATA_WIDTH - 1:0] data_in,
  input [SHIFT_BITS_WIDTH - 1:0] shift_bits,
  input rotate_left_right,
  output logic [DATA_WIDTH - 1:0] data_out
);

  always_comb begin
    if (rotate_left_right) begin
      // Perform left rotate operation
      data_out = {data_in[SHIFT_BITS_WIDTH +: (DATA_WIDTH - SHIFT_BITS_WIDTH)], data_in[SHIFT_BITS_WIDTH - 1 : 0]};
    end else begin
      // Perform right shift operation
      data_out = data_in[SHIFT_BITS_WIDTH - 1 : 0];
    end
  end

endmodule