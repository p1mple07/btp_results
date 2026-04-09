module dbi_enc(
  dbi_enable,
  rst_n,
  clk,
  data_in,
  dbi_cntrl,
  data_out
);

  parameter int dbi_enable = 1; // Enable/disable data‑bus inversion

  wire [39:0] next_dbi_data_out;
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
  reg  [44:0] dbi_data_out; // Registers to latch data after DBI calculations

  assign data_out = dbi_data_out[39:0];
  assign dbi_cntrl = dbi_data_out[44:40];

  assign data_in = dbi_enable ? data_in : 45'b0;   // Invert data on low enable

  assign next_dbi_data_out = {
    ({8{dbi_bits[4]}} ^ dat4),
    ({8{dbi_bits[3]}} ^ dat3),
    ({8{dbi_bits[2]}} ^ dat2),
    ({8{dbi_bits[1]}} ^ dat1),
    ({8{dbi_bits[0]}} ^ dat0)
  };

  assign prev_dat0 = dbi_data_out[7:0];
  assign prev_dat1 = dbi_data_out[15:8];
  assign prev_dat2 = dbi_data_out[23:16];
  assign prev_dat3 = dbi_data_out[31:24];
  assign prev_dat4 = dbi_data_out[39:32];

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

endmodule
