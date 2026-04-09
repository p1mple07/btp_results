module unpack_one_hot (input logic sign, input logic size, input logic [2:0] one_hot_selector, input logic [255:0] source_reg, output logic [511:0] destination_reg);
  
  always_comb begin
    case(one_hot_selector)
      3'b001: begin
        for (int i=0; i<256; i++) begin
          destination_reg[i*8 +: 8] = {sign? {7{source_reg[i]}} : '0, source_reg[i]};
        end
      end
      3'b010: begin
        for (int i=0; i<256; i++) begin
          destination_reg[i*8 +: 8] = {sign? {7{source_reg[i]}} : '0, source_reg[i]};
        end
      end
      3'b100: begin
        if (size == 1) begin
          for (int i=0; i<256; i++) begin
            destination_reg[i*16 +: 16] = {{8{source_reg[i]}}, source_reg[i]};
          end
        end else begin
          for (int i=0; i<256; i++) begin
            destination_reg[i*8 +: 8] = {sign? {7{source_reg[i]}} : '0, source_reg[i]};
          end
        end
      end
      default: begin
        for (int i=0; i<256; i++) begin
          destination_reg[i*8 +: 8] = source_reg[i];
        end
      end
    endcase
  end
  
endmodule