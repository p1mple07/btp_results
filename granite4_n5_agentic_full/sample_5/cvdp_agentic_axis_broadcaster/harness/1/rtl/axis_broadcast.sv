module axis_broadcast (
    input logic clk,
    input logic rst_n,
    input logic signed [7:0] s_axis_tdata,
    input logic s_axis_tvalid,
    output logic s_axis_tready,
    output logic signed [7:0] m_axis_tdata_1,
    output logic m_axis_tvalid_1,
    input logic m_axis_tready_1,
    output logic signed [7:0] m_axis_tdata_2,
    output logic m_axis_tvalid_2,
    input logic m_axis_tready_2,
    output logic signed [7:0] m_axis_tdata_3,
    output logic m_axis_tvalid_3,
    input logic m_axis_tready_3
);

   // Broadcast logic: forward the received data to all output channels
   always @(posedge clk or negedge rst_n) 
   begin
      if (~rst_n) 
      begin
         // Copy the received data to all output channels
         // Example implementation
         assign m_axis_tdata_1 = s_axis_tdata;
         assign m_axis_tdata_2 = s_axis_tdata;
         assign m_axis_tdata_3 = s_axis_tdata;
      end
   endmodule