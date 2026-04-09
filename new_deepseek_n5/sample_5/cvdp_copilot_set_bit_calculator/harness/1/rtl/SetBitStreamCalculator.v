module SetBitStreamCalculator(
    input bit i_bit_in,
    input clock i_clk,
    input ready i_ready,
    input active_low rst_n,
    output bit[8] o_set_bit_count
);

    parameter p_max_set_bit_count_width = 8;

    reg bit state = 0;
    reg [p_max_set_bit_count_width-1:0] set_bit_count = 0;

    always @(posedge i_clk) begin
        if (i_ready && state == 1) begin
            if (i_bit_in) begin
                if (set_bit_count < (1 << p_max_set_bit_count_width) - 1) begin
                    set_bit_count <= set_bit_count + 1;
                end else begin
                    set_bit_count <= (1 << p_max_set_bit_count_width) - 1;
                end
            end
        end
        else if (i_ready) begin
            state = 0;
            set_bit_count = 0;
        end
    end

    always @* begin
        if (rst_n) begin
            state = 0;
            set_bit_count = 0;
        end
    end

    // Testbench code here
endmodule