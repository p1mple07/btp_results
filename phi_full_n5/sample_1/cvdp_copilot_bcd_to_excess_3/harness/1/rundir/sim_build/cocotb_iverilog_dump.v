module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/bcd_to_excess_3.fst");
    $dumpvars(0, bcd_to_excess_3);
end
endmodule
