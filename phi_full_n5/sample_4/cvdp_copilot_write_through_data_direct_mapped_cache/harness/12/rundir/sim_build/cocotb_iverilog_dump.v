module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/ddm_cache.fst");
    $dumpvars(0, ddm_cache);
end
endmodule
