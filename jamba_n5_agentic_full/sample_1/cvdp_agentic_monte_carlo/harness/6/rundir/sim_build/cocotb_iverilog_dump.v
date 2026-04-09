module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/monte_carlo_dsp_monitor_top.fst");
    $dumpvars(0, monte_carlo_dsp_monitor_top);
end
endmodule
