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
    reg [31:0] m_axis_data = 0;
    reg s_axis_ready = 0;

    always_comb begin
        if (resetn) begin
            m_axis_valid = 0;
            s_axis_ready = 0;
        else begin
            case (dfmt_enable)
                0: begin
                    m_axis_valid = 1;
                    if (s_axis_valid) begin
                        m_axis_data = s_axis_data;
                        m_axis_data = (m_axis_data << 8) | (4'b0000);
                    end
                end
                1: begin
                    m_axis_valid = 1;
                    if (s_axis_valid) begin
                        // Sign extension
                        bit sign_bit = (s_axis_data & 8'h10000000) >> 23;
                        sign_bit = (dfmt_se) ? sign_bit : 0;
                        sign_bit = (dfmt_type) ? (~sign_bit) : sign_bit;
                        m_axis_data = (s_axis_data << 8) | (4#(sign_bit));
                    end
                end
            endcase
        end
    end

endmodule