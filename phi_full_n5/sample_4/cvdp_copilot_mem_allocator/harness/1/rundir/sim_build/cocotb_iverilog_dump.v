module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cvdp_copilot_mem_allocator.fst");
    $dumpvars(0, cvdp_copilot_mem_allocator);
end
endmodule
