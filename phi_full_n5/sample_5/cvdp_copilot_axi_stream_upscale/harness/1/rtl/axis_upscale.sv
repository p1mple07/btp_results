module axis_upscale(
    input clk,
    input resetn,
    input dfmt_enable,
    input dfmt_type,
    input dfmt_se,
    input s_axis_valid,
    input [23:0] s_axis_data,
    output reg m_axis_ready,
    output reg m_axis_valid,
    output [31:0] m_axis_data
);

reg [31:0] temp_data;

always @(posedge clk) begin
    if (resetn) begin
        m_axis_ready <= 0;
        m_axis_valid <= 0;
        m_axis_data <= 32'b0;
    end else begin
        if (s_axis_valid) begin
            if (dfmt_enable) begin
                if (dfmt_type) begin
                    temp_data = {s_axis_data[22:0], ~s_axis_data[22]};
                end else begin
                    temp_data = {s_axis_data[22:0], s_axis_data[22]};
                end
            end else begin
                temp_data = {32'b0, s_axis_data};
            end

            m_axis_ready <= 1;
            m_axis_valid <= 1;
            m_axis_data <= temp_data;
        end else begin
            m_axis_ready <= 0;
            m_axis_valid <= 0;
            m_axis_data <= 32'b0;
        end
    end
end

endmodule
