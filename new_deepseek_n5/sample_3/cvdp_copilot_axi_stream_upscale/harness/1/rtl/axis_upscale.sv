module axis_upscale(
    input clock,
    input resetn,
    input dfmt_enable,
    input dfmt_type,
    input dfmt_se,
    input s_axis_valid,
    input s_axis_data,
    output m_axis_valid,
    output m_axis_data
);
    // Flip-flop chain for data storage and shifting
    reg [23:0] data_reg;
    // Flip-flop for sign extension
    reg sign_ext;
    
    // Initialize flip-flops to 0
    always @* resetn ? data_reg <= 24'b0 : data_reg;
    
    // Shift input data into flip-flop chain
    always @* positive_edge clock begin
        if (s_axis_valid) begin
            data_reg[23] = s_axis_data[23];
            for (int i = 22; i >= 0; i--) begin
                data_reg[i] = data_reg[i+1];
            end
        end
    end
    // Determine sign extension
    always @* positive_edge clock begin
        if (dfmt_enable && dfmt_se) begin
            sign_ext = data_reg[0];
        else begin
            sign_ext = 0;
        end
    end
    // Construct output based on data format type
    always @* positive_edge clock begin
        if (dfmt_type) begin
            m_axis_data[31] = sign_ext;
            m_axis_data[23:0] = data_reg;
        else begin
            m_axis_data[23] = data_reg[23];
            m_axis_data[22:0] = data_reg[21:0];
            m_axis_data[31] = 0;
        end
    end
    // Set master valid when done
    always @* positive_edge clock begin
        m_axis_valid = 1;
    end
endmodule