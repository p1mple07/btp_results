module dbi_enc(
   // Inputs
   input  wire        rst_n,      // Asynchronous reset
   input  wire        clk,        // Clock
   input  wire        dbi_enable, // Enable signal for DBI operation
   input  wire [39:0] data_in,    // Data input before DBI logic
   // Outputs
   output wire [4:0]  dbi_cntrl,  // DBI control signals
   output wire [39:0] data_out    // Data output after DBI logic
   );
   
   wire [39:0] next_dbi_data_out; // Calculated DBI output
   wire [7:0] dat0;       // Data group 1 to 8               
   wire [7:0] dat1;       // Data group 9 to 16 
   wire [7:0] dat2;       // Data group 17 to 24              
   wire [7:0] dat3;       // Data group 25 to 32   
   wire [7:0] dat4;       // Data group 33 to 40 
   wire [7:0] prev_dat0;    // Previous data group 0 for DBI control
   wire [7:0] prev_dat1;    // Previous data group 1 for DBI control
   wire [7:0] prev_dat2;    // Previous data group 2 for DBI control
   wire [7:0] prev_dat3;    // Previous data group 3 for DBI control
   wire [7:0] prev_dat4;    // Previous data group 4 for DBI control
   wire [4:0] dbi_bits;     // DBI bits (one per data group)
   
   reg [44:0] dbi_data_out; // Register to latch data after DBI calculations

   // Output assignments
   assign data_out = dbi_data_out[39:0];
   assign dbi_cntrl = dbi_data_out[44:40];

   // Split input data into groups
   assign {dat4, dat3, dat2, dat1, dat0} = data_in;
   
   // Calculate DBI bits for each data group
   assign dbi_bits[4:0] = {(dbi_bit(dat4[7:0], prev_dat4[7:0])),
                           (dbi_bit(dat3[7:0], prev_dat3[7:0])),
                           (dbi_bit(dat2[7:0], prev_dat2[7:0])),
                           (dbi_bit(dat1[7:0], prev_dat1[7:0])),
                           (dbi_bit(dat0[7:0], prev_dat0[7:0]))};
   
   // Apply DBI inversion to each data group if enabled
   assign next_dbi_data_out = {({8{dbi_bits[4]}} ^ dat4),
                               ({8{dbi_bits[3]}} ^ dat3),
                               ({8{dbi_bits[2]}} ^ dat2),
                               ({8{dbi_bits[1]}} ^ dat1),
                               ({8{dbi_bits[0]}} ^ dat0)};
   
   // Get previous data groups from the registered output
   assign prev_dat0 = dbi_data_out[7:0];    // Previous data group 0
   assign prev_dat1 = dbi_data_out[15:8];    // Previous data group 1
   assign prev_dat2 = dbi_data_out[23:16];   // Previous data group 2
   assign prev_dat3 = dbi_data_out[31:24];   // Previous data group 3
   assign prev_dat4 = dbi_data_out[39:32];   // Previous data group 4

   // DBI data output register
   always @(posedge clk or negedge rst_n)
     begin: dbi_data_out_register
       if (!rst_n)
         begin
           dbi_data_out <= 45'h0;
         end
       else
         begin
           if (dbi_enable)
             dbi_data_out <= {dbi_bits, next_dbi_data_out};
           else
             dbi_data_out <= {5'b00000, data_in};
         end
     end 
   
   // Function to calculate each DBI bit
   function automatic reg dbi_bit (
     input [7:0] cur_d,  // Current data
     input [7:0] prv_d); // Previous data
     integer          i;  // Loop index
     reg [4:0] tmp;       // Counter variable
     reg [7:0] temp_dat;  // Intermediate DBI value

     tmp = 5'd0;                            
     for (i = 0; i < 8; i = i + 1)
       begin
         temp_dat[i] = cur_d[i] ^ prv_d[i];
         tmp = tmp + temp_dat[i];
       end
     dbi_bit = (tmp > 4) ? 1 : 0;
   endfunction
   
endmodule