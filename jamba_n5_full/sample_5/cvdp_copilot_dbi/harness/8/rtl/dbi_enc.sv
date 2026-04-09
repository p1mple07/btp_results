module dbi_enc(
    input  wire        rst_n,
    input  wire        clk,
    input  wire [39:0] data_in,
    input  logic       dbi_enable,
    output wire [4:0] dbi_cntrl,
    output wire [39:0] data_out,
    output reg [44:0] dbi_data_out,
    output wire [7:0] dat0, dat1, dat2, dat3, dat4,
    output wire [7:0] prev_dat0, prev_dat1, prev_dat2, prev_dat3, prev_dat4,
    output wire [4:0] dbi_bits
);

parameter logic [1:0] dbi_enable;

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

  always @(posedge clk or negedge rst_n)
    begin: dbi_enable_check
      if (!rst_n)
        begin
          dbi_cntrl <= 4'b0000;
          data_out <= 45'h0;
        end
      else
        if (dbi_enable)
          begin
            assign data_out = dbi_data_out[39:0];
            assign dbi_cntrl = dbi_data_out[44:40];
            assign next_dbi_data_out = { ({8{dbi_bits[4]}} ^ dat4 ), ({8{dbi_bits[3]}} ^ dat3 ), ({8{dbi_bits[2]}} ^ dat2 ), ({8{dbi_bits[1]}} ^ dat1 ), ({8{dbi_bits[0]}} ^ dat0 )};
            assign prev_dat0 = dbi_data_out[7:0];
            assign prev_dat1 = dbi_data_out[15:8];
            assign prev_dat2 = dbi_data_out[23:16];
            assign prev_dat3 = dbi_data_out[31:24];
            assign prev_dat4 = dbi_data_out[39:32];
            assign dbi_bits[4:0] = {(dbi_bit(dat4[7:0],prev_dat4[7:0])),
                                      (dbi_bit(dat3[7:0],prev_dat3[7:0])),
                                      (dbi_bit(dat2[7:0],prev_dat2[7:0])),
                                      (dbi_bit(dat1[7:0],prev_dat1[7:0])),
                                      (dbi_bit(dat0[7:0],prev_dat0[7:0]))};
          end
        else
          begin
            assign data_out <= 45'h0;
            assign dbi_cntrl <= 4'b0000;
            assign next_dbi_data_out <= 45'h0;
            assign prev_dat0 <= dbi_data_out[7:0];
            assign prev_dat1 <= dbi_data_out[15:8];
            assign prev_dat2 <= dbi_data_out[23:16];
            assign prev_dat3 <= dbi_data_out[31:24];
            assign prev_dat4 <= dbi_data_out[39:32];
            assign dbi_bits[4:0] <= 45'b0;
          end
    end
endmodule
