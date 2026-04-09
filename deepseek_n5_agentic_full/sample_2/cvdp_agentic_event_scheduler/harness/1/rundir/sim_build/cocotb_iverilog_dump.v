module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/event_scheduler.fst");
    $dumpvars(0, event_scheduler);
end
endmodule
