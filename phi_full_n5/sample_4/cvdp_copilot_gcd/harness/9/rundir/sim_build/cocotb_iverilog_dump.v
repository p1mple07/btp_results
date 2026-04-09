module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/gcd_3_ip.fst");
    $dumpvars(0, gcd_3_ip);
end
endmodule
