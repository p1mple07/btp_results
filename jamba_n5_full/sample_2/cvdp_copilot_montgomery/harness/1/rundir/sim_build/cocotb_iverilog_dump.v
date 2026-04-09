module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/montgomery_redc.fst");
    $dumpvars(0, montgomery_redc);
end
endmodule
