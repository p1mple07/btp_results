module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/lfu_counter_policy.fst");
    $dumpvars(0, lfu_counter_policy);
end
endmodule
