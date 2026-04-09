module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/swizzler.fst");
    $dumpvars(0, swizzler);
end
endmodule
