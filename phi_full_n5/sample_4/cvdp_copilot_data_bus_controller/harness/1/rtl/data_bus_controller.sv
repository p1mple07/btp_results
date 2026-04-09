module data_bus_controller #(
  parameter AFINITY = 0
  )(
  input         clk      ,
  input         rst_n    ,

  output reg m0_ready,
  input         m0_valid ,
  input [31:0]  m0_data  ,

  output reg m1_ready,
  input         m1_valid ,
  input [31:0]  m1_data  ,

  input         s_read   ,
  output reg s_valid,
  output [31:0] s_data 
);

  // Slave interface logic
  always @(posedge clk) begin
    if (!rst_n) begin
      s_valid <= 0;
      s_data <= {32'b0};
    end else begin
      if (s_read && s_valid) begin
        s_valid <= 1;
        s_data <= m0_data;
      end
    end
  end

  // Master_0 interface logic
  always @(posedge clk) begin
    if (!rst_n) begin
      m0_ready <= 0;
      m0_valid <= 0;
    end else begin
      if (m0_valid && m0_ready) begin
        if (AFINITY == 0) begin
          s_valid <= 1;
          s_data <= m0_data;
        end
        m0_ready <= 0;
      end
    end
  end

  // Master_1 interface logic
  always @(posedge clk) begin
    if (!rst_n) begin
      m1_ready <= 0;
      m1_valid <= 0;
    end else begin
      if (m1_valid && m1_ready) begin
        if (AFINITY == 1) begin
          s_valid <= 1;
          s_data <= m1_data;
        end
        m1_ready <= 0;
      end
    end
  end

  // Handling transactions from both masters
  always @(posedge clk) begin
    if (!rst_n) begin
      m0_ready <= 0;
      m1_ready <= 0;
    end else begin
      if (m0_ready || m1_ready) begin
        if (m0_ready) begin
          s_valid <= (AFINITY == 0);
        end else if (m1_ready) begin
          s_valid <= (AFINITY == 1);
        end
      end
    end
  end
endmodule
