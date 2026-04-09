module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cache_mshr.fst");
    $dumpvars(0, cache_mshr);
end
endmodule
