module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/direct_map_cache.fst");
    $dumpvars(0, direct_map_cache);
end
endmodule
