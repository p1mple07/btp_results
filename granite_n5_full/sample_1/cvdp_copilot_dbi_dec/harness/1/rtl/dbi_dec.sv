module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   // Outputs
   output wire [39:0] data_out   // Output data after DBI logic
   );

   // Splittingincoming data into two groups
   wire [19:0] group_1, group_0;
   assign {group_1, group_0} = data_in;

   // Decoding the data groups
   reg [19:0] group_1_reg, group_0_reg;
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         group_1_reg <= 20'd0;
         group_0_reg <= 20'd0;
      end else begin
         if (dbi_cntrl == 2'b00) begin
            group_1_reg <= ~group_1;
         end else if (dbi_cntrl == 2'b01) begin
            group_1_reg <= group_1;
         end else if (dbi_cntrl == 2'b10) begin
            group_0_reg <= ~group_0;
         end else if (dbi_cntrl == 2'b11) begin
            group_0_reg <= group_0;
         end
      end
   end

   // Combining the data groups to produce the final output
   wire [39:0] final_output;
   assign final_output = {group_1_reg[19:0], group_0_reg[19:0]};

   // Holding the output data at a known value during reset
   wire [39:0] known_value;
   assign known_value = 40'd0;
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         data_out <= known_value;
      end else begin
         data_out <= final_output;
      end
   end

endmodule