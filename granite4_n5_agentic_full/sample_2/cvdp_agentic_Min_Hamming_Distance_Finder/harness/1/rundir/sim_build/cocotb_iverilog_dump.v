module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/Min_Hamming_Distance_Finder.fst");
    $dumpvars(0, Min_Hamming_Distance_Finder);
end
endmodule
