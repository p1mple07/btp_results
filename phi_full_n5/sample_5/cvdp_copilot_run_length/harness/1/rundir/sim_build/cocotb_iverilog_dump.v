module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/run_length.fst");
    $dumpvars(0, run_length);
end
endmodule
