module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   // Outputs
   output wire [39:0] data_out   // Output data after DBI logic
   );

   // Splitting the incoming data into two 20-bit groups:
   wire [19:0] group_1;
   wire [19:0] group_0;
   
   assign {group_1, group_0} = data_in[39:18];
   
   // Decoding the data based on dbi_cntrl:
   wire [19:0] inv_group_1;
   wire [19:0] inv_group_0;
   
   always @(*) begin
      if (dbi_cntrl == 2'b00) begin
         inv_group_1 = ~group_1;
         inv_group_0 = ~group_0;
      end else begin
         inv_group_1 = group_1;
         inv_group_0 = group_0;
      end
   end
   
   // Combining the decoded groups to generate the final output:
   assign data_out = {inv_group_1, inv_group_0};
   
endmodule