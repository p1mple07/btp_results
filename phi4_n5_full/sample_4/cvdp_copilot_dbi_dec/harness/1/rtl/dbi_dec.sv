module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   // Outputs
   output wire [39:0] data_out   // Output data after DBI logic
);

   // Register to hold the decoded data
   reg [39:0] data_reg;

   // Connect the register output to the module output
   assign data_out = data_reg;

   // Asynchronous reset and synchronous data processing
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         data_reg <= 40'h00000000;
      end else begin
         // Split data_in into two 20-bit groups:
         // Group-1: bits [39:20] (MSBs)
         // Group-0: bits [19:0]  (LSBs)
         // Decode each group based on the corresponding control bit.
         // For Group-1, use dbi_cntrl[1]. For Group-0, use dbi_cntrl[0].
         data_reg <= { (dbi_cntrl[1] ? ~data_in[39:20] : data_in[39:20]),
                       (dbi_cntrl[0] ? ~data_in[19:0]  : data_in[19:0]) };
      end
   end

endmodule