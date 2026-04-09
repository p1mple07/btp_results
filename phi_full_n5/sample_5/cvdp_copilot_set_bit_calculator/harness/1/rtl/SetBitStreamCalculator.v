module SetBitStreamCalculator(
    input i_clk,
    input i_ready,
    input i_rst_n,
    input [7:0] i_bit_in,
    output reg [7:0] o_set_bit_count
);

    parameter p_max_set_bit_count_width = 8;
    reg [p_max_set_bit_count_width-1:0] count_register = 0;

    always @(posedge i_clk) begin
        if (i_rst_n) begin
            count_register <= 0;
        end else if (i_ready) begin
            if (i_bit_in) begin
                count_register <= count_register + 1;
            end
        end
    end

    assign o_set_bit_count = count_register;

endmodule
