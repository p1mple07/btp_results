      module binary_to_bcd (input logic [7:0] binary_in, output logic [11:0] bcd_out);

      reg [19:0] shift_reg;

      initial begin
        shift_reg = {12'd0, binary_in};
      end

      always_comb:
        begin
          shift_reg = {7'hF, shift_reg[19:8]};
          for (int i = 0; i < 8; i = i + 1) begin
            if ( (shift_reg[19] & 8) > 4 ) shift_reg[19] = 0;
            if ( (shift_reg[15:12] >= 16) ) shift_reg[15:12] = 0;
            if ( (shift_reg[11:8] >= 8) ) shift_reg[11:8] = 0;
            if ( (shift_reg[7:4] >= 4) ) shift_reg[7:4] = 0;
          end
          bcd_out = shift_reg[19:8];
        end

      endmodule
      