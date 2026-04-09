module spi_fsm (
    input  wire         i_clk,
    input  wire         i_rst_b,
    input  wire [15:0]  i_data_in,
    input  wire         i_enable,
    input  wire         i_fault,
    input  wire         i_clear,

    output reg          o_spi_cs_b,
    output reg          o_spi_clk,
    output reg          o_spi_data,
    output reg [4:0]    o_bits_left,
    output reg          o_done,
    output reg [1:0]    o_fsm_state,
);

initial begin
    i_rst_b ? $stop :
    always @(posedge i_clk or i_rst_b) begin
        if (i_rst_b) begin
            o_spi_cs_b <= 1'b1;
            o_spi_clk <= 0;
            o_spi_data <= 0;
            o_bits_left <= 16'd16;
            o_done <= 1'b0;
            o_fsm_state <= 2'b"00;
        end else begin
            if (i_enable) begin
                if (!i_clear) begin
                    if (i_rst_b) begin
                        // do nothing
                    end else begin
                        o_spi_cs_b <= 0;
                        o_spi_clk <= 1'b0;
                        o_spi_data <= i_data_in[0];
                        o_bits_left <= 16'd15;
                    end
                end
                o_spi_cs_b <= 0;
                o_spi_clk <= 1'b0;
                o_spi_data <= i_data_in[0];
                o_bits_left <= 16'd15;
            end
        end
    end
end

always @(*) begin
    o_spi_cs_b = i_enable && (i_rst_b ? 1'b0 : i_enable);
    o_spi_clk = i_enable && i_rst_b ? 1'b0 : i_clk;
    o_spi_data = i_enable && i_rst_b ? 1'b0 : i_data_in[0];
    o_bits_left = i_enable && i_rst_b ? 16'd16 : 5'b0;
    o_done = o_bits_left == 5'b0 ? 1'b1 : 1'b0;
    o_fsm_state = {i_enable, i_rst_b, i_enable};
end

endmodule
