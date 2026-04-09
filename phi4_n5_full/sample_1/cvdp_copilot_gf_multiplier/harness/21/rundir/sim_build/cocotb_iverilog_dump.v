module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/gf_mac.fst");
    $dumpvars(0, gf_mac);
end
endmodule
