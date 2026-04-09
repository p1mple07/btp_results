module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/rounding.fst");
    $dumpvars(0, rounding);
end
endmodule
