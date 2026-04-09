module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/fir_filter.fst");
    $dumpvars(0, fir_filter);
end
endmodule
