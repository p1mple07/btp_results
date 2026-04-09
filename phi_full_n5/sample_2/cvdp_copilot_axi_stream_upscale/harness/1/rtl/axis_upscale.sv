module axis_upscale(
    input clk,
    input resetn,
    input dfmt_enable,
    input dfmt_type,
    input dfmt_se,
    input s_axis_valid,
    input [23:0] s_axis_data,
    output reg m_axis_ready,
    output reg [31:0] m_axis_data
);

    // Internal state
    reg [31:0] temp_data;

    // Reset behavior
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            temp_data <= 32'b0;
            m_axis_ready <= 1'b0;
            m_axis_data <= 32'b0;
        end else begin
            temp_data <= s_axis_data;
        end
    end

    // Data format enable logic
    always @(posedge clk) begin
        if (dfmt_enable) begin
            case ({dfmt_type, dfmt_se})
                11'b11: temp_data = {temp_data[23:0], s_axis_data[23:0] ^ temp_data[23]};
                11'b10: temp_data = {temp_data[23:0], s_axis_data[23:0] & ~temp_data[23]};
                11'b01: temp_data = {temp_data[23:0], s_axis_data[23:0] | temp_data[23]};
                11'b00: temp_data = {temp_data[23:0], s_axis_data[23:0] & temp_data[23]};
                default: temp_data = temp_data;
            endcase
        end else begin
            temp_data = 32'b0;
        end
    end

    // Output logic
    always @(posedge clk) begin
        if (s_axis_valid) begin
            m_axis_ready <= 1'b1;
            m_axis_data <= temp_data;
        end else begin
            m_axis_ready <= 1'b0;
            m_axis_data <= 32'b0;
        end
    end

endmodule
