module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   // Outputs
   output wire [39:0] data_out   // Output data after DBI logic
   );

   // Split incoming data into two groups
   wire [19:0] group_1 = data_in[39:20];
   wire [19:0] group_0 = data_in[19:0];

   // Decode the data based on the control signals
   assign data_out[39:20] = dbi_cntrl[0]? ~group_1 : group_1;
   assign data_out[19:0]  = dbi_cntrl[1]? ~group_0 : group_0;

   // Reset behavior
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         data_out <= 40'h00_0000_0000;
      end else begin
         data_out <= data_out;
      end
   end

endmodule