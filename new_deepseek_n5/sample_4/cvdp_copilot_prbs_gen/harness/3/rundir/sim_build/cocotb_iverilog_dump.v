module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cvdp_prbs_gen.fst");
    $dumpvars(0, cvdp_prbs_gen);
end
endmodule
