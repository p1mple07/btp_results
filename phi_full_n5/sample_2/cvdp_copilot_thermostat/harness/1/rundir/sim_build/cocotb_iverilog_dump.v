module cocotb_iverilog_dump();
initial begin
    $dumpfile("/code/rundir/sim_build/thermostat.fst");
    $dumpvars(0, thermostat);
end
endmodule
