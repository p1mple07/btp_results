module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/bcd_counter.fst");
    $dumpvars(0, bcd_counter);
end
endmodule
