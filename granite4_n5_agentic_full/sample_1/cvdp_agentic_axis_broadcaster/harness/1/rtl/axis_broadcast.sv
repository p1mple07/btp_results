module axis_broadcast (
    input  logic clk,
    input  logic rst_n,
    input  logic [7:0] s_axis_tdata,
    input  logic s_axis_tvalid,
    output logic m_axis_tready
);
//... (code for handling input and output data)

always @ (posedge clk) begin
    if (!rst_n) begin
        m_axis_tready = 1;
    end
    else begin
        m_axis_tready = 0;
    end

endmodule