module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/Word_Change_Pulse.fst");
    $dumpvars(0, Word_Change_Pulse);
end
endmodule
