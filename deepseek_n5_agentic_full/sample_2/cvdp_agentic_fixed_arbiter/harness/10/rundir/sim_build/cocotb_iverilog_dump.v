module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/fixed_priority_arbiter.fst");
    $dumpvars(0, fixed_priority_arbiter);
end
endmodule
