module fibonacci_series(
    input clock,
    input rst,
    output fib_out,
    output overflow_flag
);

    reg RegA, RegB, overflow_next_cycle;
    reg[32] fib_out;
    reg overflow_flag;

    always clock positive edge when rst == 0 or overflow_next_cycle == 1:
        if rst == 0
            RegA = RegB;
            RegB = RegA + RegB;
            fib_out = RegB;
            if RegB[32] == 1
                overflow_next_cycle = 1;
        else if overflow_next_cycle == 1
            RegA = 0;
            RegB = 1;
            fib_out = 0;
            overflow_flag = 1;
            overflow_next_cycle = 0;

endmodule