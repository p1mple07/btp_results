module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/fsm.fst");
    $dumpvars(0, fsm);
end
endmodule
