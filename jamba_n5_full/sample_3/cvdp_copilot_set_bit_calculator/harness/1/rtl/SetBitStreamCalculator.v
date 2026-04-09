module SetBitStreamCalculator(
    input wire i_bit_in,
    input wire i_clk,
    input wire i_ready,
    input wire i_rst_n,
    output reg o_set_bit_count
);

reg [6:0] count; // choose width based on p_max_set_bit_count_width; default 8
reg async_reset;

initial begin
    async_reset = 1;
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) async_reset = 0;
    if (i_rst_n) async_reset = 1;
end

always @(posedge i_clk) begin
    if (i_ready) begin
        if (i_bit_in == 1) count = count + 1;
        else count = 0; // reset on bit 0? Actually we only count 1s.
    end
end

always @(*) begin
    o_set_bit_count = count;
end

endmodule
