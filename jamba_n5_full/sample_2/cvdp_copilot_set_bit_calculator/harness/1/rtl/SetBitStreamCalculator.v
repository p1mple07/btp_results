module SetBitStreamCalculator #(
    parameter P_MAX_SET_BIT_COUNT_WIDTH = 8
)(
    input wire i_bit_in,
    input wire i_clk,
    input wire i_ready,
    input wire i_rst_n,
    output reg o_set_bit_count
);

    parameter MAX_SET_BIT_COUNT = 1 << P_MAX_SET_BIT_COUNT_WIDTH;
    reg [P_MAX_SET_BIT_COUNT_WIDTH-1:0] count;

    initial begin
        o_set_bit_count = 0;
    end

    always @(posedge i_clk) begin
        if (i_ready) begin
            if (i_bit_in) begin
                if (count < MAX_SET_BIT_COUNT) begin
                    count <= count + 1;
                end else {
                    count <= {count[P_MAX_SET_BIT_COUNT_WIDTH-1:0], 1'b1};
                }
            end
        end else begin
            count <= 0;
        end
    end

    always @(*) begin
        if (i_rst_n) begin
            count <= 0;
        end
    end

endmodule
