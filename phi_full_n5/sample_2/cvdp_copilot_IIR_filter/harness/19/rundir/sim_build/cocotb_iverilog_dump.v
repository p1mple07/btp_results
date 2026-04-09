module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/iir_filter.fst");
    $dumpvars(0, iir_filter);
end
endmodule
