module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/halfband_fir.fst");
    $dumpvars(0, halfband_fir);
end
endmodule
