module dbi_dec (
   // Inputs
   input  wire        rst_n,     // Asynchronous reset
   input  wire        clk,       // Clock
   input  wire [39:0] data_in,   // Data input before DBI decoder logic
   input  wire [1:0]  dbi_cntrl, // Indicate data inversion enabled for each group 
   // Outputs
   output reg  [39:0] data_out   // Output data after DBI logic
   );

   // DBI Decoder: decode each 20-bit group based on the control signals.
   // Group-1: bits [39:20], Group-0: bits [19:0]
   // LSB of dbi_cntrl corresponds to Group-0, MSB corresponds to Group-1.
   always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
           data_out <= 40'h0000_0000;
       end else begin
           data_out[39:20] <= (dbi_cntrl[1] ? ~data_in[39:20] : data_in[39:20]);
           data_out[19:0]  <= (dbi_cntrl[0] ? ~data_in[19:0]  : data_in[19:0]);
       end
   end

endmodule