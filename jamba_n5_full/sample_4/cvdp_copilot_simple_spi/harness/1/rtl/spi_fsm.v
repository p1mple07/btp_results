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
    output reg [1:0]    o_fsm_state
);

    reg [1:0]  state;
    reg [4:0]  bits_remaining;

    always @(i_clk or i_rst_b) begin
        if (i_rst_b) begin
            o_spi_cs_b <= 1'b1;
            o_spi_clk <= 1'b0;
            o_spi_data <= 1'b0;
            o_bits_left <= 5'hFFFF;
            o_done <= 1'b0;
            o_fsm_state <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
        end else begin
            state <= cases (i_enable)
                {1'b1} => 0;
                1'b0 => 1;
                1'b2 => 3;
                1'b3 => 4;
                default => 2;
        endcase
    end

    always @(state) begin
        case (state)
            2'b00: begin
                // idle
                o_spi_cs_b <= 1'b1;
                o_spi_clk <= 1'b0;
                o_spi_data <= 1'b0;
                o_bits_left <= 5'hFFFF;
                o_done <= 1'b0;
                o_fsm_state <= {1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
            end
            2'b01: begin
                // transmit
                o_spi_cs_b <= 1'b0;
                o_spi_clk <= 1'b1;
                o_spi_data <= i_data_in[0];
                bits_remaining <= bits_remaining - 1;
                if (bits_remaining == 0) begin
                    o_done <= 1'b1;
                end else
                    o_done <= 1'b0;
                o_bits_left <= 5'hFFFE ^ (bits_remaining - 1);
            end
            2'b10: begin
                // clock toggle
                o_spi_clk <= 1'b0;
                o_bits_left <= bits_remaining - 1;
                o_done <= 1'b0;
                o_fsm_state <= {1'b1, 1'b0, 1'b0, 1'b0, 1'b0};
            end
            default: o_spi_cs_b <= 1'b1;
        endcase
    end

endmodule
