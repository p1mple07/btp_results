module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/perfect_squares_generator.fst");
    $dumpvars(0, perfect_squares_generator);
end
endmodule
