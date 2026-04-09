module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/enhanced_fsm_signal_processor.fst");
    $dumpvars(0, enhanced_fsm_signal_processor);
end
endmodule
