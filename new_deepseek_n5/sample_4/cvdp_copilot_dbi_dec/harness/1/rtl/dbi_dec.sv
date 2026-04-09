module dbi_dec (
   input wire rst_n,
   input wire clk,
   input wire [39:0] data_in,
   input wire [1:0] dbi_cntrl,
   output wire [39:0] data_out
);

   // Flip-flops to store the two 20-bit groups
   flip_flop data_group1 (data_in[39:20]);
   flip_flop data_group0 (data_in[19:0]);

   // Invert the groups based on the control signal
   if (dbi_cntrl[1])
      data_group1 = ~data_group1;
   if (dbi_cntrl[0])
      data_group0 = ~data_group0;

   // Combine the groups to form the output
   data_out = (data_group1 << 20) | data_group0;

   // Reset all outputs to 0 if rst_n is asserted
   always @* begin
      if (rst_n)
         data_out = 0;
   end

endmodule