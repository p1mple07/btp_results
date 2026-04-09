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
  always @* begin
    // Master 0 ready depends on slave ready
    m0_ready = s_ready;
    
    // Master 1 ready depends on slave ready
    m1_ready = s_ready;
    
    // Master 0 data is sent only if valid and ready
    m0_read = m0_valid & m0_ready;
    
    // Master 1 data is sent only if valid and ready
    m1_read = m1_valid & m1_ready;
    
    // Slave processing
    if (clk & AFINITY) begin
      // If AFINITY is 0, process m0; else process m1
      if (AFINITY == 0) begin
        s_valid = 1;
        s_data = m0_data;
      else begin
        s_valid = 0;
        // Ignore m0_data and m1_data
      end
    else begin
      // If no AFINITY or same cycle, wait for next cycle
      s_valid = 0;
    end
  end
endmodule