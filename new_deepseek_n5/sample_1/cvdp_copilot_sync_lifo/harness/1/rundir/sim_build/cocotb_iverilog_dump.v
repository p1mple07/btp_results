module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/sync_lifo.fst");
    $dumpvars(0, sync_lifo);
end
endmodule
