module axis_upscale(
    input clock,
    input resetn,
    input dfmt_enable,
    input dfmt_type,
    input dfmt_se,
    input s_axis_valid,
    input s_axis_data,
    output m_axis_valid,
    output m_axis_data,
    output s_axis_ready
);

    always_edge clock begin
        if (s_axis_valid && m_axis_ready) begin
            if (dfmt_enable == 0) begin
                m_axis_data = s_axis_data << 3 | (4'b0000);
                m_axis_valid = 1;
            else begin
                if (dfmt_type == 1) begin
                    bit [23] of s_axis_data is extended to bits 24-31;
                end else begin
                    bit [23] of s_axis_data is used as bit 24;
                end
                if (dfmt_se == 1) begin
                    bit 23 of s_axis_data is extended to bits 24-31;
                end else begin
                    bits 24-31 are zeros;
                end
                m_axis_data = extended_value;
                m_axis_valid = 1;
            end
        end else begin
            m_axis_data = 0;
            m_axis_valid = 0;
        end
        s_axis_ready = 0;
    end
endmodule