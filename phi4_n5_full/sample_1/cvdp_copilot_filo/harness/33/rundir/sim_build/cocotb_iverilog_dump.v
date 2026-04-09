module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/FILO_RTL.fst");
    $dumpvars(0, FILO_RTL);
end
endmodule
