module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/pseudoRandGenerator_ca.fst");
    $dumpvars(0, pseudoRandGenerator_ca);
end
endmodule
