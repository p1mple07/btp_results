module barrel_shifter #(parameter DATA_WIDTH = 16, parameter SHIFT_WIDTH = 4)(
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic [SHIFT_WIDTH-1:0] shift_bits,
    input  logic left_right,       // 1 for left, 0 for right
    input  logic rotate_left_right, // 1 for rotate, 0 for shift
    output logic [DATA_WIDTH-1:0] data_out
);

  // Combinational logic for shift and rotate operations
  always_comb begin
    if (!rotate_left_right) begin
      // Standard shift operation
      if (left_right)
        data_out = data_in << shift_bits;
      else
        data_out = data_in >> shift_bits;
    end else begin
      // Rotate operation: bits shifted out from one end are wrapped to the other end
      if (left_right)
        data_out = (data_in << shift_bits) | (data_in >> (DATA_WIDTH - shift_bits));
      else
        data_out = (data_in >> shift_bits) | (data_in << (DATA_WIDTH - shift_bits));
    end
  end

endmodule