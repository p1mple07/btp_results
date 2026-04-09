module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/secure_variable_timer.fst");
    $dumpvars(0, secure_variable_timer);
end
endmodule
