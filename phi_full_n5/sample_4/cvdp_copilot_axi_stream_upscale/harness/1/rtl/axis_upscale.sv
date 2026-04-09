module axis_upscale (
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

    reg [31:0] temp_data;

    always @(posedge clk or posedge resetn) begin
        if (resetn) begin
            m_axis_ready <= 0;
            m_axis_valid <= 0;
            m_axis_data <= 32'b0;
        end else begin
            if (dfmt_enable) begin
                case (dfmt_type)
                    1: temp_data = ~s_axis_data[23] ? s_axis_data : 0;
                    0: temp_data = s_axis_data[23];
                endcase

                case (dfmt_se)
                    1: temp_data = s_axis_data << 23;
                    0: temp_data = s_axis_data << 23;
                endcase

                temp_data = {temp_data, s_axis_data};
            end

            m_axis_ready <= s_axis_valid;
            m_axis_valid <= 1;
            m_axis_data <= temp_data;
        end
    end

endmodule
