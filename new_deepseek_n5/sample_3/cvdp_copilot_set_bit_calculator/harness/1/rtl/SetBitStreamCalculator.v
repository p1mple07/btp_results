module SetBitStreamCalculator(
    input bit i_bit_in,
    input clock i_clk,
    input ready i_ready,
    input active_low rst_n,
    output bit[8] o_set_bit_count
);

    // Internal signals
    reg bit reset; // Asynchronous reset
    reg bit count; // Current count of set bits
    reg bit initial; // To handle the first bit after reset

    // Enable on positive edge of clock when ready is high
    always positive edge i_clk, i_ready #+1 of clock 
        if (i_ready && !rst_n) begin
            if (i_bit_in) begin
                // Ignore the first set bit after reset
                if (!initial) begin
                    count = count + 1;
                    initial = 1;
                end else if (count < (1 << 8 - 1)) begin
                    count = count + i_bit_in;
                    if (count > (1 << 8 - 1)) begin
                        count = (1 << 8 - 1);
                    end
                end
            end else begin
                count = 0;
            end
        end else if (rst_n) begin
            count = 0;
            initial = 1;
        end

    // Reset when rst_n goes low
    always positive edge rst_n #+1 of clock 
        if (rst_n) begin
            count = 0;
            initial = 1;
        end

    // Output the count
    o_set_bit_count = count;
endmodule