module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/ahb_clock_counter.fst");
    $dumpvars(0, ahb_clock_counter);
end
endmodule
