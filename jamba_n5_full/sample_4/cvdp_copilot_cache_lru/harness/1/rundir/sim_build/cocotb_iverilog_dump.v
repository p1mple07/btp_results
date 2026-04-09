module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/pseudo_lru_nmru_policy.fst");
    $dumpvars(0, pseudo_lru_nmru_policy);
end
endmodule
