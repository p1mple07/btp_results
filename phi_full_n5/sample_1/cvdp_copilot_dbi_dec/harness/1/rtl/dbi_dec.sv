module dbi_dec (
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   output wire [39:0] data_out   // Output data after DBI logic
);

   // Internal flip-flops to hold the decoded data
   reg [39:0] group_0, group_1;

   // Always block for clocked logic
   always @(posedge clk) begin
      if (!rst_n) begin
         group_0 <= 40'b0;
         group_1 <= 40'b0;
         data_out <= group_0;
      end else begin
         // Split data_in into two groups
         group_0 <= data_in[39:20];
         group_1 <= data_in[19:0];

         // Apply DBI decoding based on dbi_cntrl
         data_out <= (dbi_cntrl == 2'b00) ? group_0 : (dbi_cntrl == 2'b01) ? group_1 : group_0 | group_1;
      end
   end

endmodule
