module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/lcm_3_ip.fst");
    $dumpvars(0, lcm_3_ip);
end
endmodule
