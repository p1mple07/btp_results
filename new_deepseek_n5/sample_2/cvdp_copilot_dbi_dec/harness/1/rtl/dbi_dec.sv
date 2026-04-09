module dbi_dec (
   input wire rst_n,
   input wire clk,
   input wire [39:0] data_in,
   input wire [1:0] dbi_cntrl,
   output wire [39:0] data_out
);

   // Split data_in into two 20-bit groups
   wire [19:0] group0;
   wire [19:0] group1;

   // Invert groups based on dbi_cntrl
   group0 = data_in[19:0] ^ (dbi_cntrl[0] ? 1:0);
   group1 = data_in[20:39] ^ (dbi_cntrl[1] ? 1:0);

   // Store inverted groups in flip-flops
   flip-flop [19:0] ff_group0, ff_group1;

   // Combine groups to form final data_out
   data_out = (ff_group1 << 20) | ff_group0;

   // Initialize flip-flops on reset
   always @* begin
      if (rst_n) begin
         ff_group0 <= 0;
         ff_group1 <= 0;
      end
   end

endmodule