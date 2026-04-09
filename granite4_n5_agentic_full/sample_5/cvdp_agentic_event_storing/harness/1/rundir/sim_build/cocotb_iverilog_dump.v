module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/event_storage.fst");
    $dumpvars(0, event_storage);
end
endmodule
