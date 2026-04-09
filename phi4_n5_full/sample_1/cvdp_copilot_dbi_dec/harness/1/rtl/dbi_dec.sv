module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset (active low)
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // 40-bit data input before DBI decoding
   input  wire [1:0]  dbi_cntrl, // Control signals for DBI decoding (LSB for LSB group, MSB for MSB group)
   // Outputs
   output wire [39:0] data_out   // 40-bit data output after DBI decoding
);

   // On every rising edge of clk or when rst_n is low, update data_out.
   // When rst_n is low, data_out is reset to 0.
   // Otherwise, decode data_in by splitting into two 20-bit groups and conditionally inverting each group.
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         data_out <= 40'b0;
      end else begin
         data_out <= { (dbi_cntrl[1] ? ~data_in[39:20] : data_in[39:20]),
                       (dbi_cntrl[0] ? ~data_in[19:0] : data_in[19:0]) };
      end
   end

endmodule