module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/async_filo.fst");
    $dumpvars(0, async_filo);
end
endmodule
