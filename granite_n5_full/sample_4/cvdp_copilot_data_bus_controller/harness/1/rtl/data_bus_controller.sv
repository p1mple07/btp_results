module data_bus_controller #(
  parameter AFINITY = 0
  )
  (
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

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    m0_read <= 1'b0;
    m1_read <= 1'b0;
    s_valid  <= 1'b0;
  end else begin
    // Implement logic for AFINITY parameter
    if(AFINITY == 0) begin
      m0_read <= 1'b1;
      m1_read <= 1'b0;
    end else begin
      m0_read <= 1'b0;
      m1_read <= 1'b1;
    end
    
    // Handle master read requests
    if(m0_valid && m0_ready) begin
      s_data <= m0_data;
      s_valid <= 1'b1;
    end else if(m1_valid && m1_ready) begin
      s_data <= m1_data;
      s_valid <= 1'b1;
    end else begin
      s_valid <= 1'b0;
    end
    
    // Handle slave write responses
    if(s_read && s_valid) begin
      m0_read <= 1'b0;
      m1_read <= 1'b0;
    end
  end
end

endmodule