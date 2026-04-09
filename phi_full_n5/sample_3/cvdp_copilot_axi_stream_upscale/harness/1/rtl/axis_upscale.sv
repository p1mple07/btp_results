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

    reg [31:0] m_axis_data_temp;

    always @(posedge clk) begin
        if (resetn) begin
            m_axis_ready <= 0;
            m_axis_valid <= 0;
            m_axis_data_temp <= 32'b0;
        end else begin
            if (dfmt_enable) begin
                if (dfmt_type) begin
                    m_axis_data_temp[23] = ~s_axis_data[23];
                end else begin
                    m_axis_data_temp[23] = s_axis_data[23];
                end
                if (dfmt_se) begin
                    m_axis_data_temp[22:0] = s_axis_data;
                end else begin
                    m_axis_data_temp[22:0] = 32'b0;
                end
            end else begin
                m_axis_data_temp = 32'b0;
            end

            m_axis_ready <= s_axis_valid;
            m_axis_valid <= 1;
            m_axis_data <= m_axis_data_temp;
        end
    end

endmodule
