module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/montgomery_mult.fst");
    $dumpvars(0, montgomery_mult);
end
endmodule
