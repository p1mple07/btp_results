module axis_upscale(
    // Clock and Reset
    input wire clk,
    input wire resetn,

    // Data Format Enable
    input wire dfmt_enable,
    input wire dfmt_type,
    input wire dfmt_se,

    // Slave Side Interface
    input wire s_axis_valid,
    input wire [23:0] s_axis_data,
    output reg s_axis_ready,

    // Master Side Interface
    output reg m_axis_valid,
    output reg [31:0] m_axis_data,
    input wire m_axis_ready
);

    reg [23:0] upscaled_data;
    reg [2:0] dfmt_reg;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            upscaled_data <= 0;
            dfmt_reg <= 0;
            s_axis_ready <= 1;
            m_axis_valid <= 0;
            m_axis_data <= 0;
        end else begin
            // Your implementation here
            if (dfmt_enable) begin
                case (dfmt_reg)
                    0: begin
                        upscaled_data <= {s_axis_data[23], s_axis_data[22:0]};
                    end
                    1: begin
                        upscaled_data <= {s_axis_data[23], ~s_axis_data[23]};
                    end
                    2: begin
                        upscaled_data <= {s_axis_data[23], s_axis_data[22:0]};
                    end
                endcase

                if (s_axis_valid && m_axis_ready) begin
                    m_axis_valid <= 1;
                    m_axis_data <= (dfmt_se? {upscaled_data[23], 2'b00} : {2'b00, upscaled_data[23]});
                end else begin
                    m_axis_valid <= 0;
                end
            end else begin
                upscaled_data <= {24{1'b0}};
                m_axis_valid <= 0;
            end

            s_axis_ready <= 1;
        end
    end
endmodule