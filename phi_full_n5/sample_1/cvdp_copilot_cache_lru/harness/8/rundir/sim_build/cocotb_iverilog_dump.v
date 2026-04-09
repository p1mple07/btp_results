module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/lru_counter_policy.fst");
    $dumpvars(0, lru_counter_policy);
end
endmodule
