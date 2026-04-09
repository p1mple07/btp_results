module axis_resize (
    input                                           clk,          //Global clock signal: Signals are sampled on the rising edge of clk
    input                                           resetn,       //The global reset signal: resetn is synchronous active-LOW reset.

    input                                           s_valid,      //The s_axis_valid signal indicates that the slave is driving a valid transfer.
    output  reg                                     s_ready,      //The s_axis_ready indicates that the slave can accept a transfer in the current cycle.
    input       [15:0]  s_data,                                   //The s_axis_data is the primary payload data from slave.

    output  reg                                     m_valid,      //The m_axis_valid indicates that the master is driving a valid transfer.
    input                                           m_ready,      //The m_axis_ready indicates that the slave can accept a transfer in the current cycle.
  output  reg [7:0] m_data                                      //The m_axis_data is the primary payload data to master.
);

always @(posedge clk or posedge resetn) begin
    if (resetn) begin
        m_data <= 0;
        s_ready <= 1;
        m_valid <= 0;
    end else begin
        m_data <= s_data[7:0];
        s_ready <= 1;
        m_valid <= 1;
    end
end

endmodule
