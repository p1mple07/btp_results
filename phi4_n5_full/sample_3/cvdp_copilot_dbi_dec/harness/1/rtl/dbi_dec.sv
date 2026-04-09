module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Control signals for inversion (LSB for group0, MSB for group1)
   // Outputs
   output wire [39:0] data_out   // Data output after DBI decoding
   );

   // Split data_in into two 20-bit groups:
   // Group1: bits [39:20] (most significant)
   // Group0: bits [19:0]  (least significant)

   // On reset, force data_out to 0.
   // On clock edge, decode based on dbi_cntrl:
   // - For group0, if dbi_cntrl[0] is 1, invert data_in[19:0]
   // - For group1, if dbi_cntrl[1] is 1, invert data_in[39:20]

   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         data_out <= 40'h00000000;
      end else begin
         data_out <= { (dbi_cntrl[1] ? ~data_in[39:20] : data_in[39:20]),
                       (dbi_cntrl[0] ? ~data_in[19:0]  : data_in[19:0]) };
      end
   end

endmodule