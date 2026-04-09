module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/fibonacci_series.fst");
    $dumpvars(0, fibonacci_series);
end
endmodule
