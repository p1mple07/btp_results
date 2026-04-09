module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/clock_jitter_detection_module.fst");
    $dumpvars(0, clock_jitter_detection_module);
end
endmodule
