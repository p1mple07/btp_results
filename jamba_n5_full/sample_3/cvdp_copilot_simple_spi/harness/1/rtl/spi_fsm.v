module spi_fsm (
    input  wire         i_clk,
    input  wire         i_rst_b,
    input  wire [15:0] i_data_in,
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

reg [4:0] bit_counter;

always @(posedge i_clk or negedge i_rst_b) begin
    if (!i_rst_b) begin
        o_spi_cs_b <= 1'b1;
        o_spi_clk <= 1'b0;
        o_spi_data <= 1'b0;
        o_bits_left <= 16'hFFFF;
        o_done <= 1'b0;
        o_fsm_state <= 00;
    end else begin
        if (i_enable) begin
            if (i_clk) begin
                o_spi_cs_b <= 1'b0;
                o_spi_clk <= ~o_spi_clk;
                o_spi_data <= i_data_in[7]; // MSB first
                if (bit_counter > 0) bit_counter <= bit_counter - 1;
                if (bit_counter == 0) o_done <= 1'b1;
            end else begin
                // idle
            end
        end else begin
            o_spi_cs_b <= 1'b1;
            o_spi_clk <= 0;
            o_spi_data <= 1'b0;
        end
    end
end

always @(*) begin
    o_fsm_state = {o_done, o_bits_left};
end

endmodule
