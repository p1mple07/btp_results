module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/lfsr_8bit.fst");
    $dumpvars(0, lfsr_8bit);
end
endmodule
