module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/dual_port_memory.fst");
    $dumpvars(0, dual_port_memory);
end
endmodule
