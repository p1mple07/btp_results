module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/mru_counter_policy.fst");
    $dumpvars(0, mru_counter_policy);
end
endmodule
