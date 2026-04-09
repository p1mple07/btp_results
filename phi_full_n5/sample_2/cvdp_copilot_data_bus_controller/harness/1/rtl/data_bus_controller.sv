module data_bus_controller #(
  parameter AFINITY = 0
  )(
  input         clk      ,
  input         rst_n    ,

  output reg m0_read  = 0,
  input         m0_valid ,
  input [31:0]  m0_data  ,

  output reg m1_read  = 0,
  input         m1_valid ,
  input [31:0]  m1_data  ,

  input         s_read   ,
  output reg s_valid  = 0,
  output [31:0] s_data 
);

  always_ff @(posedge clk) begin
    if (rst_n) begin
      m0_read <= 0;
      m1_read <= 0;
      s_valid <= 0;
    end else begin
      if (m0_valid && m1_valid) begin
        if (AFINITY == 0) begin
          s_valid <= 1;
          s_data <= m0_data;
          m0_read <= 0;
          m1_read <= 0;
        end else if (AFINITY == 1) begin
          s_valid <= 1;
          s_data <= m1_data;
          m0_read <= 0;
          m1_read <= 0;
        end
      end else if (m0_valid) begin
        s_valid <= 1;
        s_data <= m0_data;
        m0_read <= 0;
        m1_read <= 0;
      end else if (m1_valid) begin
        s_valid <= 1;
        s_data <= m1_data;
        m0_read <= 0;
        m1_read <= 0;
      end
    end
  end

  always_comb begin
    s_ready <= s_valid && m0_valid && m1_valid;
    m0_ready <= s_valid && m0_valid && !s_ready;
    m1_ready <= s_valid && m1_valid && !s_ready;
  end

endmodule
