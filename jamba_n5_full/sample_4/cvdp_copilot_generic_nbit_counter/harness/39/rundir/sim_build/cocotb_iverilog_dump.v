module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/generic_counter.fst");
    $dumpvars(0, generic_counter);
end
endmodule
