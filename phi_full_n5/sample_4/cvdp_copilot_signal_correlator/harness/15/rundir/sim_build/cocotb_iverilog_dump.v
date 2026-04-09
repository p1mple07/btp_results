module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/signal_correlator.fst");
    $dumpvars(0, signal_correlator);
end
endmodule
