module dbi_enc (
  input  wire        rst_n,   // Asynchronous reset
  input  wire        clk,     // Clock
  input  wire        dbi_enable, // Enable / Disable DBI logic
  input  wire [39:0] data_in, // Data input before DBI logic
  output wire [4:0] dbi_cntrl,
  output wire [39:0] data_out // Data output after DBI logic
);
  
  //... (rest of the original code remains unchanged)

  always @(posedge clk or negedge rst_n)
  begin: dbi_en_process
    if (!rst_n)
    begin
      dbi_data_out <= 45'h0;
    end
    else
    begin
      dbi_data_out <= {dbi_bits,next_dbi_data_out};
    end
  end
  
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
  dbi_bit = (tmp > 4)? 1 : 0;

  endfunction

endmodule