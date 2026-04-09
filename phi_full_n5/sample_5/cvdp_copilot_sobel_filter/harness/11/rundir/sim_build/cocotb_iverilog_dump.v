module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/sobel_filter.fst");
    $dumpvars(0, sobel_filter);
end
endmodule
