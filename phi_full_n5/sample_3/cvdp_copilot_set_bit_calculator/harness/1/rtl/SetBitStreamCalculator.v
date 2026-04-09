module SetBitStreamCalculator(
    input wire i_clk,
    input wire i_ready,
    input wire i_rst_n,
    input wire [7:0] i_bit_in,
    output reg [7:0] o_set_bit_count
);

parameter p_max_set_bit_count_width = 8;

// State register
reg [p_max_set_bit_count_width-1:0] count_reg;

always @(posedge i_clk) begin
    if (i_rst_n) begin
        count_reg <= 0;
    end else if (i_ready) begin
        count_reg <= count_reg + (i_bit_in == 1);
    end
end

// Output logic with saturation
assign o_set_bit_count = (count_reg < p_max_set_bit_count_width) ? count_reg : p_max_set_bit_count_width-1;

endmodule
