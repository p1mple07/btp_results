module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/GP.fst");
    $dumpvars(0, GP);
end
endmodule
