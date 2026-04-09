module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/round_robin_arbiter.fst");
    $dumpvars(0, round_robin_arbiter);
end
endmodule
