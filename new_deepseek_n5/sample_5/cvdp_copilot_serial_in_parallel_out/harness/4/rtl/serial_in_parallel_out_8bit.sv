module serial_in_parallel_out_8bit (
    input clock,
    input serial_in,
    output parallel_out
);

    reg parallel_out = 8'b0;
    reg state = 0;

    always clock_edge begin
        state <= state + 1;
        if (state < 8)
            parallel_out = (parallel_out << 1) | serial_in;
        else
            parallel_out = parallel_out;
    end

endmodule