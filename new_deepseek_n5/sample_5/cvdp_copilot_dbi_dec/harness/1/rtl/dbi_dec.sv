module dbi_dec (
   input wire rst_n,
   input wire clk,
   input wire [39:0] data_in,
   input wire [1:0] dbi_cntrl,
   output wire [39:0] data_out
);

   reg group1, group0;

   if (rst_n) begin
      group1 = 0;
      group0 = 0;
   else begin
      group1 = (data_in[39:20]);
      group0 = (data_in[19:0]);

      if (dbi_cntrl[0]) begin
         group1 = group1 ^ 0x00FFFFFF;
         group0 = group0 ^ 0x00FFFFFF;
      end

      data_out = (group1 << 20) | group0;
   end

endmodule