module data_bus_controller #(
  parameter AFINITY = 0
) (
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

reg [31:0] m0_pending_data;
reg [31:0] m1_pending_data;
reg m0_ready;
reg m1_ready;
reg slave_ready;
reg master_selected;

always @(posedge clk or posedge rst_n) begin
  if (!rst_n) begin
    m0_ready <= 0;
    m1_ready <= 0;
    slave_ready <= 0;
    master_selected <= 0;
    m0_pending_data <= 0;
    m1_pending_data <= 0;
  end else begin
    if (m0_ready) begin
      if (m0_valid && m0_data != 0) begin
        slave_ready <= 1;
        m0_pending_data <= m0_data;
        m0_ready <= 0;
      end
    end

    if (m1_ready) begin
      if (m1_valid && m1_data != 0) begin
        slave_ready <= 1;
        m1_pending_data <= m1_data;
        m1_ready <= 0;
      end
    end
  end
end

assign m0_read = slave_ready;
assign m1_read = slave_ready;

assign slave_ready = (AFINITY == 0) ? m0_ready : m1_ready;

assign s_valid = slave_ready;
assign s_data = slave_pending_data;

endmodule
