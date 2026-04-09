module SetBitStreamCalculator(
    input wire i_bit_in,
    input clock i_clk,
    input ready i_ready,
    input reset i_rst_n,
    output reg [p_max_set_bit_count_width-1:0] o_set_bit_count
);

    reg [p_max_set_bit_count_width-1:0] count;
    reg state = 0; // 0: idle, 1: counting

    always @(posedge i_clk) begin
        if (i_ready && state == 1) begin
            if (i_bit_in) begin
                count = min(count + 1, (1 << p_max_set_bit_count_width) - 1);
            end
        end
        state = 1;
    end

    always @* begin
        if (i_rst_n) begin
            count = 0;
            state = 0;
        end
    end

    // Ensure count doesn't overflow
    integer max_count = (1 << p_max_set_bit_count_width) - 1;
    integer current_count = 0;
    integer bit_in_value = 0;

    initial begin
        $break;
    end

    // Testbench code here
endmodule