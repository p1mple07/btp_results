module fibonacci_series(
    input wire clock,
    input wire rst,
    output wire fib_out,
    output wire overflow_flag
);
    reg RegA, RegB;
    reg overflow_reg;
    reg fib_out_next;
    reg overflow_flag_next;
    
    always clocked begin
        if (rst) begin
            RegA = 0;
            RegB = 1;
            fib_out = 0;
            overflow_flag = 0;
        end else begin
            next_fib = RegA + RegB;
            overflow_flag_next = (next_fib >> 32);
            fib_out_next = RegB;
        end
        fib_out = fib_out_next;
        overflow_flag = overflow_flag_next;
    end
    RegA = RegA + (overflow_flag_next & 1);
    RegB = RegB + (overflow_flag_next & 2);
endmodule