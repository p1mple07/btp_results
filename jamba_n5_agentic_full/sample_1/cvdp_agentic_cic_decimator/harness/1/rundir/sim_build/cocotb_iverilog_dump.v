module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/cic_decimator.fst");
    $dumpvars(0, cic_decimator);
end
endmodule
