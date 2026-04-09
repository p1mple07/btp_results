module SetBitStreamCalculator #(
    parameter int p_max_set_bit_count_width = 8
) (
    input wire i_clk,
    input wire i_ready,
    input wire i_rst_n,
    input wire i_bit_in,
    output reg [p_max_set_bit_count_width - 1:0] o_set_bit_count
);

reg [p_max_set_bit_count_width - 1:0] count;

always @(posedge i_clk or posedge i_rst_n) begin
    if (!i_rst_n) begin
        count <= 0;
    end else if (i_ready && i_bit_in) begin
        count <= count + 1;
    end
end

assign o_set_bit_count = count;

endmodule