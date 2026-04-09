module data_bus_controller #(
  parameter AFINITY = 0
  )(
  input         clk      ,
  input         rst_n    ,

  output        m0_read  ,
  input         m0_valid ,
  input [31:0]  m0_data  ,

  output        m1_read  ,
  input         m1_valid ,
  input [31:0]  m1_data  ,

  input         s_read   ,
  output        s_valid  ,
  output [31:0] s_data 
);

  logic s_ready, m0_ready, m1_ready;

  always @(posedge clk) begin
    if (!rst_n) begin
      s_valid <= 0;
      m0_valid <= 0;
      m1_valid <= 0;
      s_data <= {32'b0};
      m0_data <= {32'b0};
      m1_data <= {32'b0};
    end else begin
      if (s_read) begin
        s_ready <= 1;
        s_valid <= m0_valid & (AFINITY == 0);
        s_data <= m0_data;
      end
      if (m0_read) begin
        m0_ready <= 1;
        m0_valid <= m0_valid;
        if (AFINITY == 0) begin
          m0_data <= m0_data;
        end
      end
      if (m1_read) begin
        m1_ready <= 1;
        m1_valid <= m1_valid;
        if (AFINITY == 1) begin
          m1_data <= m1_data;
        end
      end
      if (s_ready & (m0_ready | m1_ready)) begin
        m0_ready <= 0;
        m1_ready <= 0;
      end
    end
  end
endmodule
