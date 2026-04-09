module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/gf_multiplier.fst");
    $dumpvars(0, gf_multiplier);
end
endmodule
