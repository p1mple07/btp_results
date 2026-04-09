module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   // Outputs
   output wire [39:0] data_out   // Output data after DBI logic
   );

   reg [39:0] group_0, group_1;

   // Splitting Incoming Data
   assign group_0 = data_in[39:20];
   assign group_1 = data_in[19:0];

   // Decoding the Data
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         group_0 <= 40'b0;
         group_1 <= 40'b0;
      end else begin
         if (dbi_cntrl == 2'b00) begin
            group_0 <= ~group_0;
         end
         if (dbi_cntrl == 2'b01) begin
            group_1 <= ~group_1;
         end
      end
   end

   // Combining Decoded Groups
   assign data_out = {group_0, group_1};

endmodule
