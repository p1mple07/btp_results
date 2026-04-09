module data_bus_controller #(
  parameter AFINITY = 0
  )(
  input         clk     ,
  input         rst_n   ,

  output        m0_read ,
  input         m0_valid,
  input [31:0]  m0_data ,

  output        m1_read ,
  input         m1_valid,
  input [31:0]  m1_data ,

  input         s_read  ,
  output        s_valid ,
  output [31:0] s_data 
);

graph LR;
    M0--data-->S;
    M0--valid-->S;
    S--ready-->M0;
    M1--data-->S;
    M1--valid-->S;
    S--ready-->M1;