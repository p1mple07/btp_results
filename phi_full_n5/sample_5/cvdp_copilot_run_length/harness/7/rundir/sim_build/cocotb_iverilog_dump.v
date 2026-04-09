module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/parallel_run_length.fst");
    $dumpvars(0, parallel_run_length);
end
endmodule
