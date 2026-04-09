module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   // Outputs
   output wire [39:0] data_out   // Output data after DBI logic
   );

   // Internal wires for splitting and decoding
   wire [39:0] group_1, group_0;

   // Splitting the 40-bit input into two 20-bit groups
   assign group_1 = data_in[39:20];
   assign group_0 = data_in[19:0];

   // Decoding logic based on dbi_cntrl
   assign group_1 = (dbi_cntrl == 2'b00) ? group_1 : ~group_1;
   assign group_0 = (dbi_cntrl == 2'b00) ? group_0 : ~group_0;

   // Combining the decoded groups to form the output
   assign data_out = {group_1, group_0};

   // Reset logic
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         data_out <= 40'h00_0000_0000; // Reset output to all zeros
      end else begin
         data_out <= {group_1, group_0}; // Normal operation
      end
   end

endmodule
