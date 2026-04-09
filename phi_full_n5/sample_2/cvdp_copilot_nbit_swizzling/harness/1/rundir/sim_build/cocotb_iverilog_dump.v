module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/nbit_swizzling.fst");
    $dumpvars(0, nbit_swizzling);
end
endmodule
