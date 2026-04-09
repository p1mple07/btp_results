module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/sorting_engine.fst");
    $dumpvars(0, sorting_engine);
end
endmodule
