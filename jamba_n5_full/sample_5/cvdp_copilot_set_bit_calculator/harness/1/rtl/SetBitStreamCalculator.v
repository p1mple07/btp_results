module SetBitStreamCalculator #(
    parameter P_MAX_SET_BIT_COUNT_WIDTH = 8
)(
    input wire i_bit_in,
    input wire i_clk,
    input wire i_ready,
    input wire i_rst_n
);

reg [P_MAX_SET_BIT_COUNT_WIDTH - 1] o_set_bit_count;

always @(posedge i_clk or posedge i_rst_n) begin
    if (i_rst_n) begin
        o_set_bit_count <= 0;
    end else begin
        if (i_ready) begin
            // Increment only on rising edge of i_clk
            if (i_bit_in == 1) begin
                o_set_bit_count <= o_set_bit_count + 1;
            end
        end else begin
            // Only reset when i_ready goes high again after deassertion
            if (~i_ready) begin
                o_set_bit_count <= 0;
            end
        end
    end
end

initial begin
    #5 o_set_bit_count = 0; // initial state
end

endmodule
