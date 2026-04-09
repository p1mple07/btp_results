module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/complex_multiplier.fst");
    $dumpvars(0, complex_multiplier);
end
endmodule
