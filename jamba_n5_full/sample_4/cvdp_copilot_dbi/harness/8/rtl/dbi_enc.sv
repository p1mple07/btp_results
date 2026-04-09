module dbi_enc(
   // Inputs
   input  wire        rst_n,   // Asynchronous reset
   input  wire        clk,     // Clock
   input  wire [39:0] data_in, // Data input before DBI logic
   input  wire dbi_enable, // Enable/disable data bus inversion
   output wire [4:0] dbi_cntrl,
   output wire [39:0] data_out // Data output after DBI logic
);

  wire [39:0] next_dbi_data_out;
  wire [7:0] dat0;
  wire [7:0] dat1;
  wire [7:0] dat2;
  wire [7:0] dat3;
  wire [7:0] dat4;
  wire [7:0] prev_dat0;
  wire [7:0] prev_dat1;
  wire [7:0] prev_dat2;
  wire [7:0] prev_dat3;
  wire [7:0] prev_dat4;
  wire [4:0] dbi_bits;
  reg  [44:0] dbi_data_out;

  assign data_out = dbi_data_out[39:0];
  assign dbi_cntrl = dbi_data_out[44:40];
  assign {dat4,dat3,dat2,dat1,dat0} = data_in;
  assign dbi_bits[4:0] = {(dbi_bit(dat4[7:0],prev_dat4[7:0])),
                          (dbi_bit(dat3[7:0],prev_dat3[7:0])),
                          (dbi_bit(dat2[7:0],prev_dat2[7:0])),
                          (dbi_bit(dat1[7:0],prev_dat1[7:0])),
                          (dbi_bit(dat0[7:0],prev_dat0[7:0]))};
  assign next_dbi_data_out = {({8{dbi_bits[4]}} ^ dat4 ),
                              ({8{dbi_bits[3]}} ^ dat3 ),
                              ({8{dbi_bits[2]}} ^ dat2),
                              ({8{dbi_bits[1]}} ^ dat1),
                              ({8{dbi_bits[0]}} ^ dat0)};
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
          dbi_data_out <= {dbi_bits,next_dbi_data_out};
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

  // Conditional operation based on dbi_enable
  if (dbi_enable) begin
    assign data_out = dbi_data_out[39:0];
    assign dbi_cntrl = dbi_data_out[44:40];
  end
  else
    begin
      // No operation when dbi_enable is low
    end

endmodule
