module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/instruction_cache_controller.fst");
    $dumpvars(0, instruction_cache_controller);
end
endmodule
