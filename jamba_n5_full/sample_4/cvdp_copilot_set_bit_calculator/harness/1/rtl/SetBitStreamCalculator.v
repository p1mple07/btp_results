module SetBitStreamCalculator (
    input i_bit_in,
    input i_clk,
    input i_ready,
    input i_rst_n,
    output reg o_set_bit_count
);

    localparam MAX_COUNT = 1 << p_max_set_bit_count_width;
    reg [MAX_COUNT-1:0] count;
    reg async_reset;

    initial begin
        async_reset = 1;
        count = 0;
    end

    always @(posedge i_clk or posedge i_rst_n) begin
        async_reset <= 1'b0;

        if (i_rst_n) async_reset <= 1'b1;

        if (i_ready && ~i_rst_n) begin
            if (i_bit_in) count = count + 1;
        end else if (i_ready) begin
            async_reset <= 1'b1;
            count = 0;
        end
    end

    assign o_set_bit_count = count;

endmodule
