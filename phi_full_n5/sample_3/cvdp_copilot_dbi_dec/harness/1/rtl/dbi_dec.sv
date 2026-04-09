module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   // Outputs
   output wire [39:0] data_out   // Output data after DBI logic
   );

   // Internal wires
   reg [39:0] group_1, group_0;

   // Splitting incoming data into two groups
   assign group_1 = {data_in[38:0], data_in[39:1]};
   assign group_0 = {data_in[28:0], data_in[39:2]};

   // Decoding each group based on dbi_cntrl
   always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
           group_1 <= 40'h0000_0000;
           group_0 <= 40'h0000_0000;
       end else begin
           case (dbi_cntrl)
              2'b00: group_1 <= group_1;
              2'b01: group_1 <= ~group_1;
              2'b10: group_0 <= group_0;
              2'b11: group_0 <= ~group_0;
               default: group_1 <= 40'h0000_0000;
               group_0 <= 40'h0000_0000;
           endcase
       end
   end

   // Combining decoded groups to form the output
   assign data_out = {group_1, group_0};

endmodule
