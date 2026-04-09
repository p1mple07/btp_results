module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/swizzler_supervisor.fst");
    $dumpvars(0, swizzler_supervisor);
end
endmodule
