module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/fifo_policy.fst");
    $dumpvars(0, fifo_policy);
end
endmodule
