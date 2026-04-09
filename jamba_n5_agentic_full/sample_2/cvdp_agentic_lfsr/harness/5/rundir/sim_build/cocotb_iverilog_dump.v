module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/bit16_lfsr.fst");
    $dumpvars(0, bit16_lfsr);
end
endmodule
