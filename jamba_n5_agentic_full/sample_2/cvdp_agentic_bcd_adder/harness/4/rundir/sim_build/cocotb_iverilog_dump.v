module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/bcd_top.fst");
    $dumpvars(0, bcd_top);
end
endmodule
