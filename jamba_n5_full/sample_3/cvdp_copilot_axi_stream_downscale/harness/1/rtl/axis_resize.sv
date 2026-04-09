module axis_resize (
    input                                           clk,
    input                                           resetn,

    input                                           s_valid,
    output  reg                                     s_ready,
    input       [15:0]  s_data,

    output  reg                                     m_valid,
    input                                           m_ready,
    output  reg [7:0] m_data
);

always @(posedge clk or posedge resetn) begin
    if (resetn) begin
        m_data <= 0;
        s_ready <= 1;
        m_valid <= 1;
    end else begin
        m_data <= s_data[7:0];
        s_ready <= 1;
        m_valid <= 1;
    end
end

endmodule
