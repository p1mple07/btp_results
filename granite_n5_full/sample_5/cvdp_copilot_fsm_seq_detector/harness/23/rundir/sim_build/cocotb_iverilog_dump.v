module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/fsm_seq_detector.fst");
    $dumpvars(0, fsm_seq_detector);
end
endmodule
