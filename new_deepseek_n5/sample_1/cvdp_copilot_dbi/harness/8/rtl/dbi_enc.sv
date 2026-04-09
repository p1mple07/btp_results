module dbi_enc(
   // Inputs
   input  wire        rst_n,   
   input  wire        clk,    
   input  wire [39:0] data_in, 
   input  wire        dbi_enable,
   // Outputs
   output wire [4:0] dbi_cntrl,
   output wire [39:0] data_out // Data output after DBI logic
   );
   wire [39:0] next_dbi_data_out; //calculated dbi_out
   wire [7:0] dat0;       //  data group 1 to 8               
   wire [7:0] dat1;       // data group 9 to 16 
   wire [7:0] dat2;       //  data group 17 to 24              
   wire [7:0] dat3;       // data group 25 to 32   
   wire [7:0] dat4;       // data group  33 to 40 
   wire [7:0] prev_dat0;    // Prev data group                           
   wire [7:0] prev_dat1;    // Prev data group
   wire [7:0] prev_dat2;    // Prev data group                           
   wire [7:0] prev_dat3;    // Prev data group                 
   wire [7:0] prev_dat4;    // Prev data group                 
   wire [4:0] dbi_bits;     // dbi_bits[0]       
                            // dbi_bits[1] 
   reg  [44:0] dbi_data_out; // Registers to latch data after DBI calculations
   
   assign data_out = dbi_data_out[39:0];
   assign dbi_cntrl = dbi_data_out[44:40];
   assign {dat4,dat3,dat2,dat1,dat0} = data_in;
   assign dbi_bits[4:0] = {(dbi_bit(dat4[7:0],prev_dat4[7:0])),
                   (dbi_bit(dat3[7:0],prev_dat3[7:0])),
                   (dbi_bit(dat2[7:0],prev_dat2[7:0])),
                   (dbi_bit(dat1[7:0],prev_dat1[7:0])),
                   (dbi_bit(dat0[7:0],prev_dat0[7:0]))};
                   
   always @(posedge clk or negedge rst_n)
   begin: dbi_data_out_register
     if (!rst_n)
       begin
         dbi_data_out <= 45'h0;
       end
     else
       begin
         if (dbi_enable)
           dbi_data_out <= {dbi_bits,next_dbi_data_out};
         else
           dbi_data_out <= dbi_data_out;
       end
   end
   
   
   
   // Function to calculate each DBI bit                          
function automatic reg dbi_bit (
  input [7:0] cur_d,  // Current data
  input [7:0] prv_d); // Previous data
  integer          i;  // Integer index
  reg [4:0] tmp;       // Counter Variable
  reg [7:0] temp_dat;  // Intermediate DBI value

  tmp = 5'd0;                            
  for (i=0; i<8; i=i+1)                 
    begin                                
      temp_dat[i] = cur_d[i] ^ prv_d[i];  
      tmp = tmp + temp_dat[i];            
    end                              
 dbi_bit = (tmp > 4) ? 1 : 0;

endfunction
   
   
   
endmodule