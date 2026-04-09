module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/gcd_top.fst");
    $dumpvars(0, gcd_top);
end
endmodule
