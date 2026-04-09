module dbi_enc(
   // Inputs
   input  wire        rst_n,        // Asynchronous reset
   input  wire        clk,          // Clock
   input  wire        dbi_enable,  // Enable signal for data bus inversion
   input  wire [39:0] data_in,      // Data input before DBI logic
   // Outputs
   output wire [4:0] dbi_cntrl,
   output wire [39:0] data_out      // Data output after DBI logic
   );

   wire [39:0] next_dbi_data_out; // Calculated dbi_out
   wire [7:0] dat0;              // Data group 1 to 8
   wire [7:0] dat1;              // Data group 9 to 16
   wire [7:0] dat2;              // Data group 17 to 24
   wire [7:0] dat3;              // Data group 25 to 32
   wire [7:0] dat4;              // Data group 33 to 40
   wire [4:0] dbi_bits;           // dbi_bits[0]       
                                    // dbi_bits[1]
   reg  [44:0] dbi_data_out;   // Registers to latch data after DBI calculations

   always @(posedge clk or negedge rst_n)
     begin
       if (!rst_n)
         begin
           dbi_data_out <= 45'h0;
         end
       else
         begin
           dbi_data_out <= {dbi_bits, next_dbi_data_out};
         end
     end

   function automatic reg dbi_bit (
     input [7:0] cur_d,         // Current data
     input [7:0] prv_d);        // Previous data
     integer          i;            // Integer index
     reg [4:0] tmp;             // Counter variable
     reg [7:0] temp_dat;        // Intermediate DBI value

     tmp = 5'd0;                   
     for (i=0; i<8; i=i+1)         
       begin
         temp_dat[i] = cur_d[i] ^ prv_d[i]; 
         tmp = tmp + temp_dat[i];    
       end                       
     dbi_bit = (tmp > 4)? 1 : 0;

   endfunction

   assign data_out = dbi_data_out[39:0];
   assign dbi_cntrl = dbi_data_out[44:40];
   assign {dat4, dat3, dat2, dat1, dat0} = data_in;

   // DBI data output registered
   always @(posedge clk or negedge rst_n)
     begin: dbi_data_out_register
       if (!rst_n)
         begin
           dbi_data_out <= 45'h0;
         end
       else
         begin
           dbi_data_out <= {dbi_bits, next_dbi_data_out};
         end
     end

   // Enable DBI operation
   always @(posedge clk or negedge rst_n)
     begin
       if (!rst_n)
         begin
           dbi_bits <= 4'd0;
         end
       else
         begin
           dbi_bits <= {dbi_bits[1:0], dbi_enable};
         end
     end

   // Assign next dbi_data_out based on dbi_enable signal
   always @(posedge clk or negedge rst_n)
     begin
       if (!rst_n)
         begin
           next_dbi_data_out <= 40'd0;
         end
       else if (dbi_enable == 1'b1)
         begin
           next_dbi_data_out <= {({8{dbi_bits[4]}} ^ dat4),
                                  ({8{dbi_bits[3]}} ^ dat3),
                                  ({8{dbi_bits[2]}} ^ dat2),
                                  ({8{dbi_bits[1]}} ^ dat1),
                                  ({8{dbi_bits[0]}} ^ dat0)};
         end
       else
         begin
           next_dbi_data_out <= dbi_data_out;
         end
     end

endmodule