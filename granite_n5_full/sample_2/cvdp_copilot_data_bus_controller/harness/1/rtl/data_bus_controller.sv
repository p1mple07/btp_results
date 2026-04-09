module data_bus_controller #(
  parameter AFINITY = 0
  ) (
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
  
  // Clock & Reset
  logic clk_i, rst_n_i;
  assign clk_i = clk;
  assign rst_n_i = rst_n;
  
  // Data Bus Controller Logic
  always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      // Reset values
      m0_read <= 1'b0;
      m1_read <= 1'b0;
      s_valid <= 1'b0;
      s_data <= 32'b0;
    end else begin
      // Check master readiness
      if (m0_ready && m0_valid) begin
        // Send data from m0 to s
        s_valid <= 1'b1;
        s_data <= m0_data;
      end else if (m1_ready && m1_valid) begin
        // Send data from m1 to s
        s_valid <= 1'b1;
        s_data <= m1_data;
      end else begin
        // Wait for master readiness
        s_valid <= 1'b0;
      end
      
      // Check if slave has received data
      if (s_read && s_valid) begin
        // Clear valid signal
        s_valid <= 1'b0;
      end
    end
  end
  
endmodule