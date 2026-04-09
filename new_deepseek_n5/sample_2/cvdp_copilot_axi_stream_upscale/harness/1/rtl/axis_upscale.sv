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

    // Reset handling
    always @* begin
        if (resetn) begin
            s_axis_ready = 1;
            m_axis_valid = 0;
            m_axis_data = 8'b00000000;
        end else begin
            // Data processing
            if (dfmt_enable) begin
                // Perform data formatting
                if (dfmt_type) begin
                    // Inverted MSB carry forward
                    s_axis_data[23] = ~s_axis_data[23];
                end else begin
                    // Normal MSB carry forward
                    s_axis_data[23] = s_axis_data[23];
                end

                if (dfmt_se) begin
                    // Sign extension
                    s_axis_data[22:0] = s_axis_data[23] & s_axis_data[22:0];
                end else begin
                    // Zero extension
                    s_axis_data[22:0] = 8'b00000000;
                end

                // Upscale to 32 bits
                m_axis_data = (s_axis_data << 8) | s_axis_data[23:23];
                m_axis_data[31] = 0;
            else begin
                // No data formatting, just pad with zeros
                m_axis_data = (s_axis_data << 8) | 8'b00000000;
                m_axis_data[31] = 0;
            end
        end
    end

    // Set ready state based on s_axis_valid
    s_axis_ready = s_axis_valid;
endmodule