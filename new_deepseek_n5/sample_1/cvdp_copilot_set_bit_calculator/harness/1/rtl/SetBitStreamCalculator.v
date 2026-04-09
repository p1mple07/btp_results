module SetBitStreamCalculator(
    input bit i_bit_in,
    input clock i_clk,
    input ready i_ready,
    input active_low rst_n,
    output bit_o_set_bit_count
);

    // Initialize count to 0
    reg [p_max_set_bit_count_width-1:0] o_set_bit_count = 0;

    // Asynchronous reset handling
    always_comb begin
        if (rst_n)
            o_set_bit_count = 0;
    end

    // Synchronous reset on rising edge of clock when ready is asserted
    event i_ready_rising;
    always clock_edge_i_clk begin
        if (i_ready) begin
            // Ignore first bit after assertion
            if (o_set_bit_count == 0)
                o_set_bit_count = 0;
        end
    end

    // Counting logic
    always clock_edge_i_clk begin
        if (i_ready) begin
            if (i_bit_in) begin
                o_set_bit_count = o_set_bit_count + 1;
                // Saturate if exceeds max value
                if (o_set_bit_count > (2 ** p_max_set_bit_count_width - 1))
                    o_set_bit_count = (2 ** p_max_set_bit_count_width - 1);
            end
        end
    end
endmodule