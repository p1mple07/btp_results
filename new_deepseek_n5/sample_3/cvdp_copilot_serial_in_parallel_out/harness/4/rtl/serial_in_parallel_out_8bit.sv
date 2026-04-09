module serial_in_parallel_out_8bit (
    input clock,
    input serial_in,
    output parallel_out[7:0]
);

    // Flip-flops for each bit
    flip_flop f0 (clk=+clock, q=parallel_out[0]);
    flip_flop f1 (clk=+clock, q=parallel_out[1]);
    flip_flop f2 (clk=+clock, q=parallel_out[2]);
    flip_flop f3 (clk=+clock, q=parallel_out[3]);
    flip_flop f4 (clk=+clock, q=parallel_out[4]);
    flip_flop f5 (clk=+clock, q=parallel_out[5]);
    flip_flop f6 (clk=+clock, q=parallel_out[6]);
    flip_flop f7 (clk=+clock, q=parallel_out[7]);

    // Connect each flip-flop's data input to the next flip-flop's output
    serial_in  -> f0.D;
    f0.q -> f1.D;
    f1.q -> f2.D;
    f2.q -> f3.D;
    f3.q -> f4.D;
    f4.q -> f5.D;
    f5.q -> f6.D;
    f6.q -> f7.D;

endmodule