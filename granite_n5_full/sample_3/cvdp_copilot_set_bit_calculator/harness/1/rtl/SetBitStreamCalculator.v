module SetBitStreamCalculator #(parameter p_max_set_bit_count_width = 8) (
    input wire i_clk,
    input wire i_ready,
    input wire i_rst_n,
    input wire i_bit_in,
    output reg [p_max_set_bit_count_width-1:0] o_set_bit_count
);

    always @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            o_set_bit_count <= 0;
        end else if (i_ready) begin
            o_set_bit_count <= o_set_bit_count + (i_bit_in & ~o_set_bit_count[p_max_set_bit_count_width-1]);
        end
    end

endmodule