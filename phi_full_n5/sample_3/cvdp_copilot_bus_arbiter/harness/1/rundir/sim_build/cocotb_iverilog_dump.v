module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cvdp_copilot_bus_arbiter.fst");
    $dumpvars(0, cvdp_copilot_bus_arbiter);
end
endmodule
