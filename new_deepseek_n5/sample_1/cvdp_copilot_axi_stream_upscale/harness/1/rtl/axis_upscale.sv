module axis_upscale(
    input clock,
    input resetn,
    input dfmt_enable,
    input dfmt_type,
    input dfmt_se,
    input s_axis_valid,
    input s_axis_data,
    output m_axis_ready,
    output m_axis_valid,
    output m_axis_data
);

    // Reset behavior
    if(resetn) begin
        m_axis_data = 0;
        m_axis_ready = 1;
        return;
    end

    // No data processing if reset is active
    if(!s_axis_valid) begin
        m_axis_data = 0;
        m_axis_ready = 1;
        return;
    end

    // No data format enabled
    if(!dfmt_enable) begin
        m_axis_data = s_axis_data << 8;
        m_axis_valid = 1;
        return;
    end

    // Apply data format type and sign extension
    wire (s_axis_data >> 23) as msb;
    wire extended_bit;

    if(dfmt_type == 0) begin
        extended_bit = msb;
    else begin
        extended_bit = ~msb;
    end

    if(dfmt_se) begin
        extended_bit = extended_bit & 1;
        extended_bit = extended_bit << 24;
    end

    m_axis_data = (extended_bit) | (s_axis_data << 24);
    m_axis_valid = 1;

endmodule