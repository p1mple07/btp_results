module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/dig_stopwatch_top.fst");
    $dumpvars(0, dig_stopwatch_top);
end
endmodule
