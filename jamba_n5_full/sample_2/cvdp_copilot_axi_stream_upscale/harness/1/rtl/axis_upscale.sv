module axis_upscale (
    input wire clk,
    input wire resetn,
    input wire dfmt_enable,
    input wire dfmt_type,
    input wire dfmt_se,
    input wire s_axis_valid,
    input wire s_axis_data,
    input wire m_axis_ready,
    output reg s_axis_ready,
    output reg m_axis_valid,
    output reg [31:0] m_axis_data
);

always @(posedge clk or posedge resetn) begin
    if (resetn) begin
        s_axis_ready <= 0;
        m_axis_valid <= 0;
        m_axis_data <= 32'd0;
    end else begin
        s_axis_ready <= 1;
        m_axis_valid <= 1;
        // ... generate data ...
    end
end

always @(*) begin
    if (dfmt_enable) begin
        // Inverted MSB carry forward
        if (dfmt_type == 1) begin
            m_axis_data[31:0] = {s_axis_data[23:0], s_axis_data[22]};
        end else begin
            // default carry forward? maybe extend with 0?
            m_axis_data[31:0] = {s_axis_data[23], s_axis_data[22:0]};
        end
    end else begin
        m_axis_data = s_axis_data;
    end
end

endmodule
