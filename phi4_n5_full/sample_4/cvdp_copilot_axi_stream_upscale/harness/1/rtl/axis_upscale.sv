module axis_upscale (
    input  logic         clk,
    input  logic         resetn,
    input  logic         dfmt_enable,
    input  logic         dfmt_type,
    input  logic         dfmt_se,
    input  logic         s_axis_valid,
    input  logic [23:0]  s_axis_data,
    input  logic         m_axis_ready,
    output logic         s_axis_ready,
    output logic         m_axis_valid,
    output logic [31:0]  m_axis_data
);

    // Internal register to hold valid flag and processed data.
    logic valid_reg;
    logic [31:0] data_reg;

    // Single pipeline stage register: capture and format the input data.
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            valid_reg  <= 1'b0;
            data_reg   <= 32'b0;
        end
        else begin
            // Accept new data when slave is valid and module is ready.
            if (s_axis_valid && s_axis_ready) begin
                if (dfmt_enable) begin
                    // When data format is enabled, format the 24-bit input to 32 bits.
                    if (dfmt_se) begin
                        // Sign extension: use s_axis_data[23] (or its inverted value)
                        // as the fill value for the upper 8 bits.
                        data_reg <= {8{{(dfmt_type ? ~s_axis_data[23] : s_axis_data[23])}}, s_axis_data};
                    end
                    else begin
                        // No sign extension: fill upper bits with a constant.
                        // If dfmt_type is 1, fill with '1'; otherwise, fill with '0'.
                        data_reg <= {8{{(dfmt_type ? 1'b1 : 1'b0)}}, s_axis_data};
                    end
                end
                else begin
                    // When data format is disabled, simply pad the upper 8 bits with zeros.
                    data_reg <= {8'b0, s_axis_data};
                end
                valid_reg <= 1'b1;
            end
            // Release the valid data when master accepts it.
            else if (valid_reg && m_axis_ready) begin
                valid_reg <= 1'b0;
            end
        end
    end

    // Handshake signals: s_axis_ready is asserted when there is no data pending.
    assign s_axis_ready = m_axis_ready && ~valid_reg;
    // m_axis_valid indicates that formatted data is available.
    assign m_axis_valid = valid_reg;
    // Drive the processed data to the master.
    assign m_axis_data  = data_reg;

endmodule