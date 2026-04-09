module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cvdp_copilot_perf_counters.fst");
    $dumpvars(0, cvdp_copilot_perf_counters);
end
endmodule
