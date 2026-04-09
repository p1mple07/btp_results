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

    // Internal signals
    reg [23:0] upscaled_data;
    reg [31:0] extended_data;

    // Reset condition
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            m_axis_ready <= 0;
            m_axis_valid <= 0;
            m_axis_data <= 32'b0;
        end else begin
            m_axis_ready <= s_axis_valid;
            m_axis_valid <= 1;
        end
    end

    // Data format enable logic
    always @(posedge clk) begin
        if (dfmt_enable) begin
            if (dfmt_type == 1) begin
                upscaled_data <= {upscaled_data, ~s_axis_data[23]};
            end else begin
                upscaled_data <= upscaled_data << 1;
                upscaled_data <= upscaled_data | s_axis_data[23];
            end
        end else begin
            upscaled_data <= s_axis_data;
        end
    end

    // Sign extension logic
    always @(posedge clk) begin
        if (dfmt_se) begin
            extended_data <= {extended_data, s_axis_data[22:1]};
        end else begin
            extended_data <= upscaled_data << 1;
            extended_data <= extended_data | s_axis_data[22];
        end
    end

    // Final data output
    assign m_axis_data = extended_data;

endmodule
