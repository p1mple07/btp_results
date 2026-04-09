module unpack_one_hot(
  input  logic sign,
  input  logic size,
  input  logic [2:0] one_hot_selector,
  input  logic [255:0] source_reg,
  output logic [511:0] destination_reg
);

  always_comb begin : p_unpack
    case (one_hot_selector)
      // Default assignment
      default:
        destination_reg = source_reg;

      // Unpack 1-bit, 2-bit, 4-bit, or 8-bit segments from the packed input
      `ONE_HOT_CASE(3'b001):
        for (int i = 0; i < 8; i++) begin
          if (sign)
            destination_reg[i*8 +: 8] = {8{source_reg[i]}};
          else
            destination_reg[i*8 +: 8] = source_reg[i];
        end
      `ONE_HOT_CASE(3'b010):
        for (int i = 0; i < 4; i++) begin
          if (sign)
            destination_reg[i*8 +: 8] = {8{source_reg[i*2 +: 2]}};
          else
            destination_reg[i*8 +: 8] = source_reg[i*2 +: 2];
        end
      `ONE_HOT_CASE(3'b100):
        if (size == 1) begin
          for (int i = 0; i < 8; i++) begin
            if (sign)
              destination_reg[i*16 +: 16] = {16{source_reg[i*2 +: 2]}};
            else
              destination_reg[i*16 +: 16] = source_reg[i*2 +: 2];
          end
        end else begin
          for (int i = 0; i < 4; i++) begin
            if (sign)
              destination_reg[i*8 +: 8] = {8{source_reg[i*2 +: 2]}};
            else
              destination_reg[i*8 +: 8] = source_reg[i*2 +: 2];
          end
        end
      endcase
  end

endmodule